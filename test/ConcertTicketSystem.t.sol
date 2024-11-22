// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {VotingSystem} from "../src/ConcertTicketSystem.sol";

contract ConcertTicketSystemTest is Test {
    ConcertTicketSystem public concertTicketSystem;
    NFTFactory public nftFactory;
    address public owner = address(0x1);
    address public user = address(0x2);
    address public reseller = address(0x3);
    uint256 public concertId;
    string public baseIPFSHash = "QmTestHash"; // Sample IPFS hash

    //Deploy the required contracts and set up initial state
    function setUp() public {
        vm.startPrank(owner);

        // Deploy the NFTFactory
        nftFactory = new NFTFactory();

        // Deploy the ConcertTicketSystem contract
        concertTicketSystem = new ConcertTicketSystem(address(nftFactory));

        vm.stopPrank();
    }

    //add ticket class
    ticketClasses[0] = ConcertTicketSystem.TicketClass({
            "VIP",
            1 ether,
            100,
            block.timestamp + 1 days,
            block.timestamp + 10 days,
            true,
            2 ether
        });

    //helper function
    function addConcert() public{
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            ticketClasses
        );
    }

    function buyTicket(uint256 _concertId, uint256 _ticketClassIndex) public{
        concertTicketSystem.buyTicket(_concertId, _ticketClassIndex);
    }
}

contract AddConcertTest is ConcertTicketSystemTest{
    function setUp() public override{
        super.setUp();
    }
    
    
    //happy path
    function test_AddConcert() public{
        vm.startPrank(Owner);
        addConcert();
        vm.expectEmit(true, false, false, false); //debug caller event
        assertEq(concertTicketSystem._concertIds, 1);
        vm.expectEmit(true, true, true, false); //emit ticketClassAdded event
        vm.expectEmit(true, true, true, false); //emit concertAdded event
        vm.stopPrank();
    }

    //unhappy path
    function test_RevertIf_InvalidArtistName_AddConcert() public{
        vm.startPrank(Owner);
        vm.expectRevert("Artist name cannot be empty");
        concertTicketSystem.addConcert(
            "",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            ticketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidVenue_AddConcert() public{
        vm.startPrank(Owner);
        vm.expectRevert("Venue cannot be empty");
        concertTicketSystem.addConcert(
            "Artist Name",
            "",
            block.timestamp + 20 days,
            "ART",
            baseIPFSHash,
            ticketClasses);
        vm.stopPrank();
    }

    function test_RevertIf_InvalidDate_AddConcert() public{
        vm.startPrank(Owner);
        vm.expectRevert("Concert date must be in the future");
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp - 20 days,
            "ART",
            baseIPFSHash,
            ticketClasses);
        vm.stopPrank();
    }        

    function test_RevertIf_InvalidTicketClass_AddConcert() public{
        ConcertTicketSystem.TicketClass[] _emptyTicketClasses;
        vm.startPrank(Owner);
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
        ConcertTicketSystem.TicketClass[] _emptyTicketClasses;
        vm.startPrank(Owner);
        vm.expectRevert("IPFS hash cannot be empty");
        concertTicketSystem.addConcert(
            "Artist Name",
            "Venue Name",
            block.timestamp + 20 days,
            "ART",
            "",
            ticketClasses);
        vm.stopPrank();
    }
}

contract BuyTicketTest is ConcertTicketSystemTest{
    function setUp() public override{
        super.setUp();
    }

    //happy path
    function test_BuyTicket() public{
        vm.prank(owner);
        addConcert();
        vm.startPrank(user);
        vm.warp(ticketClasses[0].startBuy);
        buyTicket(1,0);
        vm.expectEmit(true, true, true, true);
    }

    //unhappy path
    
}