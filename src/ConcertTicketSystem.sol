// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTFactory.sol";
import "./ConcertTicketNFT.sol";

contract ConcertTicketSystem is Ownable {
    uint256 private _concertIds;

    NFTFactory public nftFactory;
    mapping(uint256 => address) public concertNFTs;

    struct TicketClass {
        string name;
        uint256 price;
        uint256 quantity;
        uint256 startBuy;
        uint256 endBuy;
    }

    struct Concert {
        string artistName;
        string venue;
        uint256 date;
        string symbol;
        TicketClass[] ticketClasses;
    }

    mapping(uint256 => Concert) public concerts;

    event ConcertAdded(
        uint256 concertId,
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

    function addConcert(
        string memory _artistName,
        string memory _venue,
        uint256 _date,
        TicketClass[] memory _ticketClasses
    ) public onlyOwner {
        _concertIds++;
        uint256 newConcertId = _concertIds;

        concerts[newConcertId].artistName = _artistName;
        concerts[newConcertId].venue = _venue;
        concerts[newConcertId].date = _date;

        for (uint i = 0; i < _ticketClasses.length; i++) {
            concerts[newConcertId].ticketClasses.push(_ticketClasses[i]);
            emit TicketClassAdded(
                newConcertId,
                _ticketClasses[i].name,
                _ticketClasses[i].price,
                _ticketClasses[i].quantity
            );
        }

        // Use NFTFactory to create a new NFT contract for this concert
        string memory nftName = string(
            abi.encodePacked(_artistName, " - ", _venue, " Tickets")
        );
        string memory nftSymbol = symbol;
        address nftAddress = nftFactory.createNFT(nftName, nftSymbol);
        concertNFTs[newConcertId] = nftAddress;

        emit ConcertAdded(newConcertId, _artistName, _venue, _date);
    }

    function buyTicket(
        uint256 _concertId,
        uint256 _ticketClassIndex
    ) public payable {
        Concert storage concert = concerts[_concertId];
        require(
            _ticketClassIndex < concert.ticketClasses.length,
            "Invalid ticket class"
        );
        TicketClass storage ticketClass = concert.ticketClasses[
            _ticketClassIndex
        ];

        require(
            block.timestamp >= ticketClass.startBuy,
            "Ticket sale has not started"
        );
        require(block.timestamp <= ticketClass.endBuy, "Ticket sale has ended");
        require(msg.value >= ticketClass.price, "Insufficient payment");
        require(ticketClass.quantity > 0, "Sold out");

        address nftAddress = concertNFTs[_concertId];
        require(nftAddress != address(0), "NFT contract not set");

        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);
        string memory tokenURI = generateTokenURI(
            _concertId,
            _ticketClassIndex,
            ticketClass.quantity
        );
        uint256 tokenId = nft.safeMint(msg.sender, tokenURI);

        unchecked {
            ticketClass.quantity--;
        }

        if (msg.value > ticketClass.price) {
            payable(msg.sender).transfer(msg.value - ticketClass.price);
        }

        emit TicketPurchased(
            _concertId,
            tokenId,
            msg.sender,
            _ticketClassIndex
        );
    }

    function generateTokenURI(
        uint256 _concertId,
        uint256 _ticketClassIndex,
        uint256 _ticketNumber
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://example.com/api/ticket/",
                    toString(_concertId),
                    "/",
                    toString(_ticketClassIndex),
                    "/",
                    toString(_ticketNumber)
                )
            );
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
