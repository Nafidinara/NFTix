// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTFactory.sol";
import "./ConcertTicketNFT.sol";

contract ConcertTicketSystem is Ownable {
    uint256 private _concertIds;

    NFTFactory public nftFactory;
    mapping(uint256 => address) public concertNFTs;

    struct Concert {
        string artistName;
        string venue;
        uint256 date;
        uint256 ticketPrice;
        uint256 ticketQuantity;
        string ticketClass;
        uint256 endBuy;
    }

    mapping(uint256 => Concert) public concerts;

    event ConcertAdded(
        uint256 indexed concertId,
        string artistName,
        string venue,
        uint256 date
    );
    event TicketPurchased(
        uint256 indexed concertId,
        uint256 indexed tokenId,
        address buyer
    );
    event TicketResold(
        uint256 indexed concertId,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    constructor(address _nftFactoryAddress) Ownable(msg.sender) {
        nftFactory = NFTFactory(_nftFactoryAddress);
    }

    enum TicketClass{
        None,
        General,
        VIP,
        VVIP
    }

    function addConcert(
        string memory _artistName,
        string memory _venue,
        uint256 _date,
        uint256 _ticketPrice,
        uint256 _ticketQuantity,
        uint256 _startBuy,
        uint256 _endBuy
    ) public onlyOwner {
        _concertIds++;
        uint256 newConcertId = _concertIds;
        concerts[newConcertId] = Concert(
            _artistName,
            _venue,
            _date,
            _ticketPrice,
            _ticketQuantity,
            _startBuy,
            _endBuy
        );

        //get token symbol from parameter
        address nftAddress = nftFactory.createNFT(
            string(abi.encodePacked(_artistName, " - ", _venue)),
            "CTKTS"
        );
        concertNFTs[newConcertId] = nftAddress;

        emit ConcertAdded(newConcertId, _artistName, _venue, _date);
    }

    function buyTicket(uint256 _concertId) public payable {
        Concert storage concert = concerts[_concertId];
        require(
            block.timestamp >= concert.startBuy &&
                block.timestamp <= concert.endBuy,
            "Ticket sale is not active"
        );
        require(msg.value >= concert.ticketPrice, "Insufficient payment");
        require(concert.ticketQuantity > 0, "Sold out");

        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
        string memory tokenURI = string(
            abi.encodePacked(
                "https://example.com/api/ticket/",
                _concertId,
                "/",
                concert.ticketQuantity
            )
        );
        uint256 tokenId = nft.safeMint(msg.sender, tokenURI);

        concert.ticketQuantity--;

        emit TicketPurchased(_concertId, tokenId, msg.sender);
    }

    // function resellTicket(
    //     uint256 _concertId,
    //     uint256 _tokenId,
    //     uint256 _price
    // ) public {
    //     ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
    //     require(nft.ownerOf(_tokenId) == msg.sender, "Not the ticket owner");
    //     nft.approve(address(this), _tokenId);
    //     // Additional logic for reselling can be implemented here
    // }

    function buyResoldTicket(
        uint256 _concertId,
        uint256 _tokenId
    ) public payable {
        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
        address seller = nft.ownerOf(_tokenId);
        require(msg.sender != seller, "Seller cannot buy their own ticket");
        require(
            msg.value >= concerts[_concertId].ticketPrice,
            "Insufficient payment"
        );

        nft.safeTransferFrom(seller, msg.sender, _tokenId);
        payable(seller).transfer(msg.value);

        emit TicketResold(_concertId, _tokenId, seller, msg.sender, msg.value);
    }

    function verifyTicket(
        uint256 _concertId,
        uint256 _tokenId,
        address _attendee
    ) public view returns (bool) {
        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
        return nft.ownerOf(_tokenId) == _attendee;
    }
}
