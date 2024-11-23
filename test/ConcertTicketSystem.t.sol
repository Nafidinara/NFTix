// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/NFTFactory.sol";
import "src/ConcertTicketNFT.sol";

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ConcertTicketSystem} from "../src/ConcertTicketSystem.sol";

contract ConcertTicketSystemTest is Test {
    ConcertTicketSystem public concertTicketSystem;
    NFTFactory public nftFactory;
    address public owner = address(0x1);
    address public user = address(0x2);
    address public reseller = address(0x3);
    uint256 public concertId;
    string public baseIPFSHash = "QmTestHash"; // Sample IPFS hash

    //Deploy the required contracts and set up initial state
    function setUp() virtual public {
        vm.startPrank(owner);

        // Deploy the NFTFactory
        nftFactory = new NFTFactory();

        // Deploy the ConcertTicketSystem contract
        concertTicketSystem = new ConcertTicketSystem(address(nftFactory));

        vm.stopPrank();
    }


    //helper function
    ConcertTicketSystem.TicketClass [] _ticketClasses;
    ConcertTicketSystem.TicketClass[] _emptyTicketClasses;
    function addTicketClass() public{
        _ticketClasses.push(ConcertTicketSystem.TicketClass("VIP", 1 ether, 100, block.timestamp+1 days,
        block.timestamp + 10 days, true, 2 ether));
    }

    function addConcert() public{
        concertId=0;
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            _ticketClasses
        );
    }

    function buyTicket(uint256 _concertId, uint256 _ticketClassIndex) public{
        concertTicketSystem.buyTicket(_concertId, _ticketClassIndex);
    }

    function cancelConcert(uint256 _concertId) public{
        concertTicketSystem.cancelConcert(_concertId);
    }
}

contract AddConcertTest is ConcertTicketSystemTest{
    function setUp() public override{
        super.setUp();
    }
    
    
    //happy path
    function test_AddConcert() public{
        vm.startPrank(owner);
        addTicketClass();
        addConcert();
        vm.expectEmit(true, false, false, false); //debug caller event
        assertEq(concertId, 1);
        vm.expectEmit(true, true, true, false); //emit ticketClassAdded event
        vm.expectEmit(true, true, true, false); //emit concertAdded event
        vm.stopPrank();
    }

    //unhappy path
    function test_RevertIf_InvalidArtistName_AddConcert() public{
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Artist name cannot be empty");
        concertTicketSystem.addConcert(
            "",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            _ticketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidVenue_AddConcert() public{
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Venue cannot be empty");
        concertTicketSystem.addConcert(
            "Artist Name",
            "",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            _ticketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidDate_AddConcert() public{
        vm.startPrank(owner);
        addTicketClass();
        vm.expectRevert("Concert date must be in the future");
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp - 20 days,
            "ART",
            baseIPFSHash,
            _ticketClasses);
        vm.stopPrank();
    }        

    function test_RevertIf_InvalidTicketClass_AddConcert() public{
        vm.startPrank(owner);
        vm.expectRevert("Must have at least one ticket class");
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            _emptyTicketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidBaseIPFSHash_AddConcert() public{
        addTicketClass();
        vm.startPrank(owner);
        vm.expectRevert("IPFS hash cannot be empty");
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            "",
            _ticketClasses);
        vm.stopPrank();
    }
}

contract BuyTicketTest is ConcertTicketSystemTest{
    function setUp() public override{
        super.setUp();
    }

    //happy path
    function test_BuyTicket() public{
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.startPrank(user);
        vm.warp(_ticketClasses[0].startBuy);
        buyTicket(1,0);
        vm.expectEmit(true, true, true, true);
    }

    //unhappy path
    function test_RevertIf_ConcertDontExist() public{
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy);
        vm.expectRevert("Concert does not exist");
        buyTicket(concertId + 1,0);
    }

    function test_RevertIf_ConcertCancelled() public{
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy);
        cancelConcert(concertId);
        vm.expectRevert("Concert already cancelled");
        buyTicket(concertId,0);
    }

    function test_RevertIf_InvalidClassIndex() public{
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy);
        vm.expectRevert("Invalid ticket class");
        buyTicket(concertId, 100);
    }

    function test_RevertIf_SaleNotStarted() public{
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].startBuy - 1 days);
        vm.expectRevert("Ticket sale has not started");
        buyTicket(concertId, 0);
    }

    function test_RevertIf_SaleEnded() public{
        addTicketClass();
        vm.prank(owner);
        addConcert();
        vm.warp(_ticketClasses[0].endBuy + 1 days);
        vm.expectRevert("Ticket sale has ended");
        buyTicket(concertId ,0);
    }
}