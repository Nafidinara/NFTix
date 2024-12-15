// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/NFTFactory.sol";
import "../src/ConcertTicketNFT.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ConcertTicketSystem} from "../src/ConcertTicketSystem.sol";

error ERC721NonexistentToken(uint256 tokenId);

event ConcertAdded(
    uint256 concertId,
    string concertName,
    string artistName,
    string venue,
    uint256 date
);

event TicketClassAdded(
    uint256 concertId,
    string className,
    uint256 price,
    uint256 quantity
);

event TicketListedForResale(
    uint256 indexed concertId,
    uint256 indexed tokenId,
    uint256 price
);

event ConcertCancelled(uint256 indexed concertId);

event TicketClassRetrieved(
    uint256 indexed concertId,
    uint256 indexed tokenId,
    uint256 classIndex,
    string className
);

event NFTCreated(
    address nftAddress,
    string name,
    string symbol,
    string baseIPFSHash
);

event TicketPurchased(
    uint256 indexed concertId,
    uint256 indexed tokenId,
    address buyer,
    uint256 _ticketClassIndex
);

event TicketResold(
    uint256 indexed concertId,
    uint256 indexed tokenId,
    address seller,
    address buyer,
    uint256 price
);

event RefundIssued(
    uint256 indexed concertId,
    address recipient,
    uint256 amount
);

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
                "VIP",
                1 ether,
                100,
                true,
                2 ether,
                "https://www.thumbnailurl.com",
                "https://www.backgroundurl.com"
            )
        );
    }

    function addUnresellableTicketClass() public {
        _ticketClasses.push(
            ConcertTicketSystem.TicketClass(
                "VIP",
                1 ether,
                100,
                false,
                2 ether,
                "https://www.thumbnailurl.com",
                "https://www.backgroundurl.com"
            )
        );
    }

    function addConcert() public {
        concertId = 0;
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            baseIPFSHash,
            _ticketClasses
        );
    }

    function buyTicket(
        uint256 _concertId,
        uint256 _ticketClassIndex
    ) public payable {
        concertTicketSystem.buyTicket(_concertId, _ticketClassIndex);
    }

    function cancelConcert(uint256 _concertId) public {
        concertTicketSystem.cancelConcert(_concertId);
    }

    function resellTicket(
        uint256 _concertId,
        uint256 _tokenId,
        uint256 _price
    ) public {
        concertTicketSystem.resellTicket(_concertId, _tokenId, _price);
    }
}

contract AddConcertTest is ConcertTicketSystemTest {
    //happy path
    function test_AddConcert() public {
        // Expect NFTCreated event
        address expectedNftAddress = address(0);
        vm.expectEmit(true, true, true, true);
        emit NFTCreated(
            0x104fBc016F4bb334D775a19E8A6510109AC63E00,
            "Artist Name - Venue Name Tickets",
            "ART",
            "QmTestHash"
        );

        // Expect ConcertAdded event
        vm.expectEmit(true, true, true, true);
        emit ConcertAdded(
            1,
            "Concert Name",
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days
        );

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
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            baseIPFSHash,
            _ticketClasses
        );
        vm.stopPrank();
    }

    function test_RevertIf_InvalidVenue_AddConcert() public {
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Venue cannot be empty");
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "Artist Name",
            "",
            block.timestamp + 20 days,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            baseIPFSHash,
            _ticketClasses
        );
        vm.stopPrank();
    }

    function test_RevertIf_InvalidDate_AddConcert() public {
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Concert date must be in the future");
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "Artist Name",
            "Venue Name",
            1,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            baseIPFSHash,
            _ticketClasses
        );
        vm.stopPrank();
    }

    function test_RevertIf_InvalidTicketClass_AddConcert() public {
        vm.startPrank(owner);
        vm.expectRevert("Must have at least one ticket class");
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            baseIPFSHash,
            _emptyTicketClasses
        );
        vm.stopPrank();
    }

    function test_RevertIf_InvalidBaseIPFSHash_AddConcert() public {
        addTicketClass();
        vm.startPrank(owner);
        vm.expectRevert("IPFS hash cannot be empty");
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            "",
            _ticketClasses
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

        // Step 2: Warp time to when the ticket sale has started
        vm.warp(block.timestamp + 1 days + 1); // Assuming startBuy is set to 1 day from now in addConcert

        // Step 3: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 4: Expect an event (optional, adjust fields to match your emit)
        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user, 0);

        // Step 5: Call the buyTicket function with 1 ether as msg.value
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days);
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 4: Call the buyTicket function with 1 ether as msg.value
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Expect revert for Ticket sale has ended, simulating endBuy date + 1 days
        vm.warp(block.timestamp + 20 days + 1 days);
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        // Step 1: Assign the owner
        address mockOwner = address(0x123);
        vm.prank(owner); // Simulate contract deployment by the owner
        concertTicketSystem.transferOwnership(mockOwner);

        // Step 2: Simulate the owner as a payable address
        vm.deal(mockOwner, 0 ether); // Ensure the owner starts with 0 Ether
        vm.startPrank(mockOwner);
        payable(mockOwner).call{value: 0}(""); // Mock the owner as a payable recipient
        vm.stopPrank();

        // Step 3: Proceed with the rest of the test
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Simulate ticket purchase by `user`
        vm.startPrank(user);
        vm.warp(block.timestamp + 1 days);
        vm.deal(user, 1 ether);
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Approve the ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1);
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // List the ticket for resale
        uint256 resalePrice = 1 ether;
        vm.expectEmit(true, true, true, true);
        emit TicketListedForResale(1, 1, resalePrice);
        concertTicketSystem.resellTicket(1, 1, resalePrice);

        // Simulate ticket resale by `reseller`
        vm.stopPrank();
        vm.startPrank(reseller);
        vm.deal(reseller, 2 ether);

        // Buy Resold Ticket
        vm.expectEmit(true, true, true, true);
        emit TicketResold(1, 1, user, reseller, resalePrice);
        concertTicketSystem.buyResoldTicket{value: resalePrice}(1, 1);

        // Stop impersonating
        vm.stopPrank();

        // Verify fee distribution
        uint256 ownerBalance = mockOwner.balance;
        assertEq(
            ownerBalance,
            (resalePrice * 5) / 100,
            "Fee not transferred correctly"
        );
    }

    //unhappy path
    function test_RevertIf_TicketNotListedForResale() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate ticket purchase by `user`
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
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
        vm.warp(block.timestamp + 1 days);

        vm.expectEmit(true, true, true, true); // Expect the TicketListedForResale event
        emit ConcertCancelled(1);

        cancelConcert(1);
    }

    //unhappy path
    function test_RevertIf_ConcertCancelled() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(block.timestamp + 1 days);
        cancelConcert(1);
        vm.expectRevert("Concert already cancelled");
        cancelConcert(1);
    }
}

contract ClaimRefundTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    //happy path
    function test_ClaimRefundTest() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user);
        vm.warp(block.timestamp + 1 days);
        vm.deal(user, 1 ether);

        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user, 0);
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: User approves the contract to manage their NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1);
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 4: Cancel the concert
        vm.stopPrank();
        vm.prank(owner);
        concertTicketSystem.cancelConcert(1);

        // Step 5: Claim refund
        vm.startPrank(user);
        vm.expectEmit(true, true, true, true);
        emit RefundIssued(1, user, 1 ether);
        concertTicketSystem.claimRefund(1, 1);
        vm.stopPrank();
    }

    //unhappy path
    function test_RevertIf_ConcertNotCancelled() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user);
        vm.warp(block.timestamp + 1 days);
        vm.deal(user, 1 ether);

        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user, 0);
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: User approves the contract to manage their NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1);
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 4: Claim refund
        vm.expectRevert("Concert not cancelled");
        concertTicketSystem.claimRefund(1, 1);
        vm.stopPrank();
    }

    //unhappy path
    function test_RevertIf_CallerNotTicketOwner() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user);
        vm.warp(block.timestamp + 1 days);
        vm.deal(user, 1 ether);

        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user, 0);
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Step 3: User approves the contract to manage their NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1);
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // Step 4: Cancel the concert
        vm.stopPrank();
        vm.prank(owner);
        concertTicketSystem.cancelConcert(1);

        // Step 4: Cancel the concert
        vm.stopPrank();

        // Step 5: Claim refund
        vm.startPrank(scammer);
        vm.expectRevert("Not ticket owner");
        concertTicketSystem.claimRefund(1, 1);
        vm.stopPrank();
    }
}

contract VerifyTicketTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    //happy path
    function test_VerifyTicket() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Simulate user buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Call the buyTicket function with 1 ether as msg.value
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index

        // Step 4: Verify ticket
        bool isValid = concertTicketSystem.verifyTicket(1, 1, user);
        assertEq(isValid, true);
        vm.stopPrank(); // Stop impersonating `user`
    }

    function testVerifyTicketNotExist() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert(
            abi.encodeWithSelector(ERC721NonexistentToken.selector, 2)
        );
        concertTicketSystem.verifyTicket(1, 2, user);
    }

    function test_RevertIf_NotTicketOwner() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy

        // Step 2: Simulate user and a random address buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Call the buyTicket function with 1 ether as msg.value
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0); // Pass the concert ID and ticket class index

        // Step 4: Verify ticket
        bool isValid = concertTicketSystem.verifyTicket(1, 1, address(0x123));
        assertEq(isValid, false);
        vm.stopPrank(); // Stop impersonating `user`
    }

    function test_RevertIf_ConcertCancelled() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(block.timestamp + 1 days);
        cancelConcert(1);

        vm.expectRevert("Concert has been cancelled");
        concertTicketSystem.verifyTicket(1, 1, user);
    }

    function test_RevertIf_ConcertNotExist() public {
        addTicketClass();
        vm.expectRevert("Concert does not exist");
        concertTicketSystem.verifyTicket(1, 1, user);
    }

    function test_RevertIf_WrongConcert() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        concertTicketSystem.addConcert(
            "Concert Name",
            "Description",
            "Artist Name2",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            baseIPFSHash,
            _ticketClasses
        );
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy

        // Step 2: Simulate user and a random address buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Call the buyTicket function with 1 ether as msg.value
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);
        vm.expectRevert(
            abi.encodeWithSelector(ERC721NonexistentToken.selector, 1)
        );
        concertTicketSystem.verifyTicket(2, 1, user);
        vm.stopPrank(); // Stop impersonating `user
    }
}

contract EmergencyPauseTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    function test_RevertIf_BuyTicketWhenPaused() public {
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(block.timestamp + 1 days); // Set the block timestamp to startBuy
        concertTicketSystem.pause();

        // Step 2: Simulate user and a random address buying the ticket
        vm.startPrank(user); // Simulate `user` as the caller
        vm.deal(user, 1 ether); // Fund the `user` address with 1 ether

        // Step 3: Call the buyTicket function with 1 ether as msg.value
        vm.expectRevert();
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);
        vm.stopPrank();
    }

    function test_RevertIf_BuyResoldTicketWhenPaused() public {
        // Step 1: Assign the owner
        address mockOwner = address(0x123);
        vm.prank(owner); // Simulate contract deployment by the owner
        concertTicketSystem.transferOwnership(mockOwner);

        // Step 2: Simulate the owner as a payable address
        vm.deal(mockOwner, 0 ether); // Ensure the owner starts with 0 Ether
        vm.startPrank(mockOwner);
        payable(mockOwner).call{value: 0}(""); // Mock the owner as a payable recipient
        vm.stopPrank();

        // Step 3: Proceed with the rest of the test
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Simulate ticket purchase by `user`
        vm.startPrank(user);
        vm.warp(block.timestamp + 1 days);
        vm.deal(user, 1 ether);
        concertTicketSystem.buyTicket{value: 1 ether}(1, 0);

        // Approve the ConcertTicketSystem to manage user's NFTs
        address nftAddress = concertTicketSystem.getConcertNFT(1);
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        nft.setApprovalForAll(address(concertTicketSystem), true);

        // List the ticket for resale
        uint256 resalePrice = 1 ether;
        concertTicketSystem.resellTicket(1, 1, resalePrice);

        // Simulate ticket resale by `reseller`
        vm.stopPrank();
        //pause system
        concertTicketSystem.pause();
        vm.startPrank(reseller);
        vm.deal(reseller, 2 ether);

        // Buy Resold Ticket
        vm.expectRevert();
        concertTicketSystem.buyResoldTicket{value: resalePrice}(1, 1);

        // Stop impersonating
        vm.stopPrank();
    }
}

contract AddCartTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    // Happy path
    function test_AddCart() public {
        // Step 1: Add a ticket class and concert
        addTicketClass();
        vm.prank(owner);
        addConcert();

        // Step 2: Add item to cart
        vm.startPrank(user);
        concertTicketSystem.addCart(1, 0, 2); // ConcertId 1, TicketClassIndex 0, Quantity 2

        // Step 3: Verify cart contents
        (
            string memory concertName,
            string memory artistName,
            ConcertTicketSystem.TicketClass memory ticketClass,
            uint256 quantity
        ) = concertTicketSystem.userCarts(user, 1);

        assertEq(concertName, "Concert Name", "Incorrect concert name in cart");
        assertEq(artistName, "Artist Name", "Incorrect artist name in cart");
        assertEq(
            ticketClass.name,
            "VIP",
            "Incorrect ticket class name in cart"
        );
        assertEq(ticketClass.price, 1 ether, "Incorrect ticket price in cart");
        assertEq(quantity, 2, "Incorrect quantity in cart");

        vm.stopPrank();
    }

    // Unhappy paths
    function test_RevertIf_InvalidConcertId() public {
        vm.startPrank(user);
        vm.expectRevert("Invalid concert");
        concertTicketSystem.addCart(999, 0, 1); // Non-existent concert ID
        vm.stopPrank();
    }

    function test_RevertIf_InvalidTicketClassIndex() public {
        // Add a concert first
        addTicketClass();
        vm.prank(owner);
        addConcert();

        vm.startPrank(user);
        vm.expectRevert("Invalid ticket class");
        concertTicketSystem.addCart(1, 999, 1); // Invalid ticket class index
        vm.stopPrank();
    }
}

contract GetAllConcertsTest is ConcertTicketSystemTest {
    function setUp() public override {
        super.setUp();
    }

    // Helper function to convert uint to string
    function uintToString(
        uint256 _i
    ) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + (j % 10)));
            j /= 10;
        }
        str = string(bstr);
    }

    // Helper function to add multiple concerts
    function addMultipleConcerts(uint256 count) internal {
        for (uint256 i = 0; i < count; i++) {
            addTicketClass();
            vm.prank(owner);
            concertTicketSystem.addConcert(
                string(abi.encodePacked("Concert ", uintToString(i + 1))),
                "Description",
                string(abi.encodePacked("Artist ", uintToString(i + 1))),
                string(abi.encodePacked("Venue ", uintToString(i + 1))),
                block.timestamp + (i + 1) * 7 days,
                string(abi.encodePacked("SYM", uintToString(i + 1))),
                block.timestamp + 1 days,
                block.timestamp + 5 days,
                baseIPFSHash,
                _ticketClasses
            );
        }
    }

    // Happy path: Get all active concerts
    function test_GetAllActiveConcerts() public {
        // Add 3 concerts
        addMultipleConcerts(3);

        // Get all active concerts
        ConcertTicketSystem.Concert[]
            memory activeConcerts = concertTicketSystem.getAllConcerts(true);

        // Assert
        assertEq(activeConcerts.length, 3, "Should return 3 active concerts");
        assertEq(
            activeConcerts[0].concertName,
            "Concert 1",
            "First concert name mismatch"
        );
        assertEq(
            activeConcerts[1].concertName,
            "Concert 2",
            "Second concert name mismatch"
        );
        assertEq(
            activeConcerts[2].concertName,
            "Concert 3",
            "Third concert name mismatch"
        );
    }

    // Happy path: Get all inactive concerts (when all are active)
    function test_GetAllInactiveConcerts_WhenAllActive() public {
        // Add 3 concerts
        addMultipleConcerts(3);

        // Get all inactive concerts
        ConcertTicketSystem.Concert[]
            memory inactiveConcerts = concertTicketSystem.getAllConcerts(false);

        // Assert
        assertEq(
            inactiveConcerts.length,
            0,
            "Should return 0 inactive concerts"
        );
    }

    // Happy path: Get all concerts when no concerts exist
    function test_GetAllConcerts_WhenNoConcerts() public {
        // Get all active concerts
        ConcertTicketSystem.Concert[]
            memory activeConcerts = concertTicketSystem.getAllConcerts(true);

        // Get all inactive concerts
        ConcertTicketSystem.Concert[]
            memory inactiveConcerts = concertTicketSystem.getAllConcerts(false);

        // Assert
        assertEq(activeConcerts.length, 0, "Should return 0 active concerts");
        assertEq(
            inactiveConcerts.length,
            0,
            "Should return 0 inactive concerts"
        );
    }
}
