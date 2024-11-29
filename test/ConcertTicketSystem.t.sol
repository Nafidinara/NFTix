// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/NFTFactory.sol";
import "../src/ConcertTicketNFT.sol";

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ConcertTicketSystem} from "../src/ConcertTicketSystem.sol";

event ConcertAdded(uint256 concertId, string artistName, string venue, uint256 date);

event TicketClassAdded(uint256 concertId, string className, uint256 price, uint256 quantity);

event TicketListedForResale(uint256 indexed concertId, uint256 indexed tokenId, uint256 price);

event ConcertCancelled(uint256 indexed concertId);

event TicketClassRetrieved(uint256 indexed concertId, uint256 indexed tokenId, uint256 classIndex, string className);

event DebugCaller(address caller);

event NFTCreated(address nftAddress, string name, string symbol, string baseIPFSHash);

event TicketPurchased(uint256 indexed concertId, uint256 indexed tokenId, address buyer, uint256 _ticketClassIndex);

event TicketResold(uint256 indexed concertId, uint256 indexed tokenId, address seller, address buyer, uint256 price);

event RefundIssued(uint256 indexed concertId, address recipient, uint256 amount);

contract ConcertTicketSystemTest is Test {
    ConcertTicketSystem public concertTicketSystem;
    NFTFactory public nftFactory;
    address public owner = address(this);
    address public user = address(0x2);
    address public reseller = address(0x3);
    address public scammer = address(0x4);
    uint256 public concertId;
    string public baseIPFSHash = "QmTestHash"; // Sample IPFS hash

    //Deploy the required contracts and set up initial state
    function setUp() public virtual {
        vm.startPrank(owner);

        // Deploy the NFTFactory and set the ConcertTicketSystem as the owner
        nftFactory = new NFTFactory();
        concertTicketSystem = new ConcertTicketSystem(address(nftFactory));

        // Transfer ownership of NFTFactory to ConcertTicketSystem
        nftFactory.transferOwnership(address(concertTicketSystem));

        vm.stopPrank();
    }

    //helper function
    ConcertTicketSystem.TicketClass[] _ticketClasses;
    ConcertTicketSystem.TicketClass[] _emptyTicketClasses;

    function addTicketClass() public {
        _ticketClasses.push(
            ConcertTicketSystem.TicketClass(
                "VIP", 1 ether, 100, block.timestamp + 1 days, block.timestamp + 10 days, true, 2 ether
            )
        );
    }

    function addUnresellableTicketClass() public {
        _ticketClasses.push(
            ConcertTicketSystem.TicketClass(
                "VIP", 1 ether, 100, block.timestamp + 1 days, block.timestamp + 10 days, false, 2 ether
            )
        );
    }

    function addConcert() public {
        concertId = 0;
        concertTicketSystem.addConcert(
            "Artist Name", "Venue Name", block.timestamp + 20 days, "ART", baseIPFSHash, _ticketClasses
        );
    }

    function buyTicket(uint256 _concertId, uint256 _ticketClassIndex) public payable {
        concertTicketSystem.buyTicket(_concertId, _ticketClassIndex);
    }

    function cancelConcert(uint256 _concertId) public {
        concertTicketSystem.cancelConcert(_concertId);
    }

    function resellTicket(uint256 _concertId, uint256 _tokenId, uint256 _price) public {
        concertTicketSystem.resellTicket(_concertId, _tokenId, _price);
    }
}

contract AddConcertTest is ConcertTicketSystemTest {
    //happy path
    function test_AddConcert() public {
        // Expect the DebugCaller event
        vm.expectEmit(true, false, false, false); // Only match the indexed `caller`
        emit DebugCaller(owner);

        // Expect TicketClassAdded event
        vm.expectEmit(true, true, true, true); // Match all fields
        emit TicketClassAdded(1, "VIP", 1000000000000000000, 100);

        // Expect NFTCreated event
        address expectedNftAddress = address(0); // Keep this line
        vm.expectEmit(true, true, true, true);
        emit NFTCreated(
            0x104fBc016F4bb334D775a19E8A6510109AC63E00, // Use the variable here
            "Artist Name - Venue Name Tickets",
            "ART",
            "QmTestHash"
        );

        // Expect ConcertAdded event
        vm.expectEmit(true, true, true, true);
        emit ConcertAdded(1, "Artist Name", "Venue Name", block.timestamp + 20 days);

        // Define parameters for the test
        addTicketClass();
        // Call the function under test
        addConcert();
        // After calling addConcert(), now fetch the NFT address
        address nftAddress = concertTicketSystem.concertNFTs(1);

        // Validate state changes
        assertEq(concertTicketSystem._concertIds(), 1);
        assertEq(concertTicketSystem.concertNFTs(1), nftAddress);
        assertTrue(nftAddress != address(0), "NFT address should not be zero");
    }

    //unhappy path
    function test_RevertIf_InvalidArtistName_AddConcert() public {
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Artist name cannot be empty");
        concertTicketSystem.addConcert("", "Venue Name", block.timestamp + 20 days, "ART", baseIPFSHash, _ticketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidVenue_AddConcert() public {
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Venue cannot be empty");
        concertTicketSystem.addConcert(
            "Artist Name", "", block.timestamp + 20 days, "ART", baseIPFSHash, _ticketClasses
        );
        vm.stopPrank();
    }

    function test_RevertIf_InvalidDate_AddConcert() public {
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Concert date must be in the future");
        concertTicketSystem.addConcert("Artist Name", "Venue Name", 1, "ART", baseIPFSHash, _ticketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidTicketClass_AddConcert() public {
        vm.startPrank(owner);
        vm.expectRevert("Must have at least one ticket class");
        concertTicketSystem.addConcert(
            "Artist Name", "Venue Name", block.timestamp + 20 days, "ART", baseIPFSHash, _emptyTicketClasses
        );
        vm.stopPrank();
    }

    function test_RevertIf_InvalidBaseIPFSHash_AddConcert() public {
        addTicketClass();
        vm.startPrank(owner);
        vm.expectRevert("IPFS hash cannot be empty");
        concertTicketSystem.addConcert(
            "Artist Name", "Venue Name", block.timestamp + 20 days, "ART", "", _ticketClasses
        );
        vm.stopPrank();
    }
}

contract BuyTicketTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    //happy path
    function test_BuyTicket() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Expect an event (optional, adjust fields to match your emit)
        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user, 0);

        // Step 4: Call the buyTicket function with 1 ether as msg.value
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index

        vm.stopPrank(); // Stop impersonating `user`
    }

    //unhappy path
    function test_RevertIf_ConcertDontExist() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Expect revert for concert does not exist using id = 2
        vm.expectRevert("Concert does not exist");
        concertTicketSystem.buyTicket{value: 1 ether}(2, 0); // Pass the concert ID and ticket class index

        vm.stopPrank(); // Stop impersonating `user`
    }

    //unhappy path
    function test_RevertIf_ConcertHasBeenCancelled() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy);
        cancelConcert(1);
        vm.expectRevert("Concert has been cancelled");
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index
    }

    function test_RevertIf_InvalidClassIndex() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Expect revert for Invalid ticket class using ticket class index = 1
        vm.expectRevert("Invalid ticket class");
        concertTicketSystem.buyTicket{value: 1 ether}(1, 1); // Pass the concert ID and ticket class index

        vm.stopPrank(); // Stop impersonating `user`
    }

    function test_RevertIf_SaleNotStarted() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Expect revert for Ticket sale has not started, simulating endBuy date - 1 days
        vm.warp(_ticketClasses[0].startBuy - 1 days);
        vm.expectRevert("Ticket sale has not started");
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index

        vm.stopPrank(); // Stop impersonating `user`
    }

    function test_RevertIf_SaleEnded() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Expect revert for Ticket sale has ended, simulating endBuy date + 1 days
        vm.warp(_ticketClasses[0].endBuy + 1 days);
        vm.expectRevert("Ticket sale has ended");
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index

        vm.stopPrank(); // Stop impersonating `user`
    }
}

contract ResellTicketTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    //happy path
    function test_ResellTicket() public {
        // Step 1: Add a ticket class, concert and buy tickets
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 2: Approve ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Use the getter function
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 3: Expect emit event
        vm.expectEmit(true, true, true, true);
        emit TicketListedForResale(1, 1, 1 ether);

        // Step 4: Call the resellTicket function
        concertTicketSystem.resellTicket(1, 1, 1 ether);
        vm.stopPrank(); // Stop impersonating `user`
    }

    function test_RevertIf_NotTicketOwner() public {
        // Step 1: Add a ticket class, concert and buy tickets
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 2: Approve ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Use the getter function
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        //Step 3: Impersonate user 'scammer', expect revert
        vm.startPrank(scammer);
        vm.expectRevert("Not the ticket owner");
        concertTicketSystem.resellTicket(1, 1, 1 ether);
        vm.stopPrank();
    }

    function test_RevertIf_ExceedMaxPrice() public {
        // Step 1: Add a ticket class, concert and buy tickets
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 2: Approve ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Use the getter function
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        //Step 3: Expect revert, price exceed maximum (2 ether)
        vm.expectRevert("Price exceeds maximum allowed");
        concertTicketSystem.resellTicket(1, 1, 3 ether);
        vm.stopPrank();
    }

    function test_RevertIf_UnresellableTicket() public {
        // Step 1: Add a unrellable ticket class, concert and buy tickets
        addUnresellableTicketClass();
        vm.prank(owner);
        addConcert();
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 2: Approve ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Use the getter function
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        //Step 3: Expect revert, ticket cannot be resold
        vm.expectRevert("This ticket cannot be resold");
        concertTicketSystem.resellTicket(1, 1, 1 ether);
        vm.stopPrank();
    }

    function test_RevertIf_PriceIsZero() public {
        // Step 1: Add a ticket class, concert and buy tickets
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 2: Approve ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Use the getter function
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        //Step 3: Expect revert, price is 0
        vm.expectRevert("Price must be greater than 0");
        concertTicketSystem.resellTicket(1, 1, 0);
        vm.stopPrank();
    }
}

contract BuyResoldTicketTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    //happy path
    function test_BuyResoldTicket() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate ticket purchase by `user`
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: Approve the ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Fetch the NFT contract address
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 4: List the ticket for resale
        uint256 resalePrice = 1 ether;
        vm.expectEmit(true, true, true, true); // Expect the TicketListedForResale event
        emit TicketListedForResale(1, 1, resalePrice);
        concertTicketSystem.resellTicket(1, 1, resalePrice);

        // Step 5: Simulate ticket resale by `reseller`
        vm.stopPrank(); // Stop impersonating `user`
        vm.startPrank(reseller); // Start impersonating `reseller`
        vm.deal(reseller, 2 ether); // Fund the `reseller` address with 1 ether

        // Step 6: Buy Resold Ticket
        vm.expectEmit(true, true, true, true); // Expect the TicketResold event
        emit TicketResold(1, 1, user, reseller, resalePrice);
        concertTicketSystem.buyResoldTicket{value: resalePrice}(1, 1);

        // Stop impersonating
        vm.stopPrank();
    }

    //unhappy path
    function test_RevertIf_TicketNotListedForResale() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate ticket purchase by `user`
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: Approve the ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Fetch the NFT contract address
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        vm.stopPrank(); // Stop impersonating `user`

        // Step 4: Simulate ticket resale by `reseller`
        vm.startPrank(reseller); // Start impersonating `reseller`
        vm.deal(reseller, 2 ether); // Fund the `reseller` address with 1 ether

        // Step 5: Buy Resold Ticket, expect revert because ticket not listed for resale
        vm.expectRevert("Ticket not listed for resale");
        concertTicketSystem.buyResoldTicket{value: 1 ether}(1, 1);

        // Stop impersonating
        vm.stopPrank();
    }

    function test_RevertIf_IncorrectPaymentAmount() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate ticket purchase by `user`
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: Approve the ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Fetch the NFT contract address
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 4: List the ticket for resale
        uint256 resalePrice = 1 ether;
        vm.expectEmit(true, true, true, true); // Expect the TicketListedForResale event
        emit TicketListedForResale(1, 1, resalePrice);
        concertTicketSystem.resellTicket(1, 1, resalePrice);

        // Step 5: Simulate ticket resale by `reseller`
        vm.stopPrank(); // Stop impersonating `user`
        vm.startPrank(reseller); // Start impersonating `reseller`
        vm.deal(reseller, 2 ether); // Fund the `reseller` address with 1 ether

        // Step 6: Buy Resold Ticket, expect revert because of incorrect payment amount
        vm.expectRevert("Incorrect payment amount");
        concertTicketSystem.buyResoldTicket{value: 2 ether}(1, 1);

        // Stop impersonating
        vm.stopPrank();
    }

    function test_RevertIf_CallerIsSeller() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate ticket purchase by `user`
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
        vm.deal(user, 3 ether); // Fund the `user` address with 1 ether
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: Approve the ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1); // Fetch the NFT contract address
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 4: List the ticket for resale
        uint256 resalePrice = 1 ether;
        vm.expectEmit(true, true, true, true); // Expect the TicketListedForResale event
        emit TicketListedForResale(1, 1, resalePrice);
        concertTicketSystem.resellTicket(1, 1, resalePrice);

        // Step 6: Buy Resold Ticket, expect revert because of seller cannot buy their own ticket
        vm.expectRevert("Cannot buy your own ticket");
        concertTicketSystem.buyResoldTicket{value: 1 ether}(1, 1);

        // Stop impersonating
        vm.stopPrank();
    }
}

contract CancelConcertTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    //happy path
    function test_CancelConcertTest() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy);

        vm.expectEmit(true, true, true, true); // Expect the TicketListedForResale event
        emit ConcertCancelled(1);

        cancelConcert(1);
    }

    //unhappy path
    function test_RevertIf_ConcertCancelled() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy);
        cancelConcert(1);
        vm.expectRevert("Concert already cancelled");
        cancelConcert(1);
    }
}

// contract ClaimRefundTest is ConcertTicketSystemTest {
//     function setUp() public override {
//         super.setUp();
//     }

//     //happy path
//     function test_ClaimRefundTest() public {
//         // Step 1: Add a ticket class and concert
//         addTicketClass();
//         vm.prank(owner);
//         addConcert();

//         // Step 2: Simulate user buying the ticket
//         vm.startPrank(user); // Simulate `user` as the caller
//         vm.warp(_ticketClasses[0].startBuy); // Set the block timestamp to startBuy
//         vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

//         // Step 3: Expect an event (optional, adjust fields to match your emit)
//         vm.expectEmit(true, true, true, true);
//         emit TicketPurchased(1, 1, user, 0);

//         // Step 4: Call the buyTicket function with 1 ether as msg.value
//         concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index

//         cancelConcert(1);

//         vm.expectEmit(true, true, true, true); // Expect the TicketListedForResale event
//         emit RefundIssued(1, user, 1);
//         concertTicketSystem.claimRefund(1, 1);
//         vm.stopPrank();
//     }
// }
