// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol"; // Added for emergency stops
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // Added for reentrancy protection
import "./NFTFactory.sol";
import "./ConcertTicketNFT.sol";

contract ConcertTicketSystem is Ownable, Pausable, ReentrancyGuard {
    uint256 private _concertIds;
    uint256 public constant RESALE_FEE_PERCENTAGE = 5; // 5% fee on resales

    NFTFactory public nftFactory;
    mapping(uint256 => address) public concertNFTs;
    mapping(uint256 => mapping(uint256 => uint256)) public ticketResalePrices;
    mapping(uint256 => mapping(uint256 => TicketDetails)) public ticketDetails;
    mapping(uint256 => bool) public concertCancelled;
    mapping(uint256 => Concert) public concerts;

    struct TicketClass {
        string name;
        uint256 price;
        uint256 quantity;
        uint256 startBuy;
        uint256 endBuy;
        bool isResellable;
        uint256 maxResalePrice; // Prevent scalping
    }

    struct Concert {
        string artistName;
        string venue;
        uint256 date;
        string symbol;
        bool isActive;
        TicketClass[] ticketClasses;
    }

    // New struct for ticket details
    struct TicketDetails {
        uint256 concertId;
        uint256 ticketClassIndex;
        bool isValid;
        uint256 purchaseDate;
        bool isUsed;
    }

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
        address buyer,
        uint256 _ticketClassIndex
    );
    event TicketListedForResale(
        uint256 indexed concertId,
        uint256 indexed tokenId,
        uint256 price
    );
    event TicketResold(
        uint256 indexed concertId,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );
    event ConcertCancelled(uint256 indexed concertId);
    event RefundIssued(
        uint256 indexed concertId,
        address recipient,
        uint256 amount
    );
    event TicketClassRetrieved(
        uint256 indexed concertId,
        uint256 indexed tokenId,
        uint256 classIndex,
        string className
    );
    event DebugCaller(address caller);

    constructor(address _nftFactoryAddress) Ownable(msg.sender) {
        require(_nftFactoryAddress != address(0), "Invalid factory address");
        nftFactory = NFTFactory(_nftFactoryAddress);
    }

    modifier concertExists(uint256 _concertId) {
        require(
            _concertId > 0 && _concertId <= _concertIds,
            "Concert does not exist"
        );
        require(concerts[_concertId].isActive, "Concert is not active");
        _;
    }

    modifier notCancelled(uint256 _concertId) {
        require(!concertCancelled[_concertId], "Concert has been cancelled");
        _;
    }

    function addConcert(
        string memory _artistName,
        string memory _venue,
        uint256 _date,
        string memory symbol,
        string memory baseIPFSHash, // Add this parameter
        TicketClass[] memory _ticketClasses
    ) public {
        emit DebugCaller(msg.sender);
        require(bytes(_artistName).length > 0, "Artist name cannot be empty");
        require(bytes(_venue).length > 0, "Venue cannot be empty");
        require(_date > block.timestamp, "Concert date must be in the future");
        require(
            _ticketClasses.length > 0,
            "Must have at least one ticket class"
        );
        require(bytes(baseIPFSHash).length > 0, "IPFS hash cannot be empty");

        _concertIds++;
        uint256 newConcertId = _concertIds;

        concerts[newConcertId].artistName = _artistName;
        concerts[newConcertId].venue = _venue;
        concerts[newConcertId].date = _date;
        concerts[newConcertId].symbol = symbol;
        concerts[newConcertId].isActive = true;

        for (uint i = 0; i < _ticketClasses.length; i++) {
            require(
                _ticketClasses[i].price > 0,
                "Ticket price must be greater than 0"
            );
            require(
                _ticketClasses[i].quantity > 0,
                "Ticket quantity must be greater than 0"
            );
            require(
                _ticketClasses[i].startBuy < _ticketClasses[i].endBuy,
                "Invalid buying period"
            );
            require(
                _ticketClasses[i].endBuy < _date,
                "Buying period must end before concert"
            );

            concerts[newConcertId].ticketClasses.push(_ticketClasses[i]);
            emit TicketClassAdded(
                newConcertId,
                _ticketClasses[i].name,
                _ticketClasses[i].price,
                _ticketClasses[i].quantity
            );
        }

        string memory nftName = string(
            abi.encodePacked(_artistName, " - ", _venue, " Tickets")
        );

        // Updated NFT creation with baseIPFSHash
        address nftAddress = nftFactory.createNFT(
            nftName,
            symbol,
            baseIPFSHash
        );
        concertNFTs[newConcertId] = nftAddress;

        emit ConcertAdded(newConcertId, _artistName, _venue, _date);
    }

    function buyTicket(
        uint256 _concertId,
        uint256 _ticketClassIndex
    )
        public
        payable
        nonReentrant
        whenNotPaused
        concertExists(_concertId)
        notCancelled(_concertId)
    {
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
        require(msg.value == ticketClass.price, "Incorrect payment amount");
        require(ticketClass.quantity > 0, "Sold out");

        // Get the NFT contract
        address nftAddress = concertNFTs[_concertId];
        ConcertTicketNFT nft = ConcertTicketNFT(nftAddress);

        // Get the IPFS hash for this ticket from your mapping or generate it
        string memory ipfsHash = getIPFSHashForTicket(
            _concertId,
            _ticketClassIndex,
            ticketClass.quantity
        );

        // Mint the NFT with metadata
        uint256 tokenId = nft.safeMint(
            msg.sender,
            _concertId,
            _ticketClassIndex,
            ticketClass.quantity,
            ipfsHash
        );

        ticketClass.quantity--;

        // Store ticket details
        ticketDetails[_concertId][tokenId] = TicketDetails({
            concertId: _concertId,
            ticketClassIndex: _ticketClassIndex,
            isValid: true,
            purchaseDate: block.timestamp,
            isUsed: false
        });

        emit TicketPurchased(
            _concertId,
            tokenId,
            msg.sender,
            _ticketClassIndex
        );
    }

    // Add this function to handle IPFS hash retrieval
    function getIPFSHashForTicket(
        uint256 _concertId,
        uint256 _ticketClassIndex,
        uint256 _ticketNumber
    ) internal pure returns (string memory) {
        // In production, you would either:
        // 1. Store and retrieve the hash from a mapping
        // 2. Generate the hash deterministically
        // 3. Call an oracle for the hash

        // This is a placeholder - replace with actual implementation
        return "QmYourIPFSHash";
    }

    function resellTicket(
        uint256 _concertId,
        uint256 _tokenId,
        uint256 _price
    ) public concertExists(_concertId) notCancelled(_concertId) {
        Concert storage concert = concerts[_concertId];
        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);

        require(nft.ownerOf(_tokenId) == msg.sender, "Not the ticket owner");
        require(_price > 0, "Price must be greater than 0");

        // Find the ticket class for this token
        uint256 originalClass = getTicketClassIndex(_concertId, _tokenId);
        TicketClass storage ticketClass = concert.ticketClasses[originalClass];

        require(ticketClass.isResellable, "This ticket cannot be resold");
        require(
            _price <= ticketClass.maxResalePrice,
            "Price exceeds maximum allowed"
        );

        nft.approve(address(this), _tokenId);
        ticketResalePrices[_concertId][_tokenId] = _price;

        emit TicketListedForResale(_concertId, _tokenId, _price);
    }

    function buyResoldTicket(
        uint256 _concertId,
        uint256 _tokenId
    )
        public
        payable
        nonReentrant
        whenNotPaused
        concertExists(_concertId)
        notCancelled(_concertId)
    {
        uint256 price = ticketResalePrices[_concertId][_tokenId];
        require(price > 0, "Ticket not listed for resale");
        require(msg.value == price, "Incorrect payment amount");

        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
        address seller = nft.ownerOf(_tokenId);
        require(msg.sender != seller, "Cannot buy your own ticket");

        // Calculate fee and transfer amounts
        uint256 fee = (price * RESALE_FEE_PERCENTAGE) / 100;
        uint256 sellerAmount = price - fee;

        // Reset resale price before transfer
        ticketResalePrices[_concertId][_tokenId] = 0;

        // Transfer NFT and payments
        nft.safeTransferFrom(seller, msg.sender, _tokenId);
        payable(seller).transfer(sellerAmount);
        payable(owner()).transfer(fee); // Platform fee goes to contract owner

        emit TicketResold(_concertId, _tokenId, seller, msg.sender, price);
    }

    function cancelConcert(
        uint256 _concertId
    ) public concertExists(_concertId) {
        require(!concertCancelled[_concertId], "Concert already cancelled");
        concertCancelled[_concertId] = true;
        emit ConcertCancelled(_concertId);
    }

    function claimRefund(
        uint256 _concertId,
        uint256 _tokenId
    ) public nonReentrant {
        require(concertCancelled[_concertId], "Concert not cancelled");

        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not ticket owner");

        uint256 ticketClass = getTicketClassIndex(_concertId, _tokenId);
        uint256 refundAmount = concerts[_concertId]
            .ticketClasses[ticketClass]
            .price;

        // Burn the ticket NFT
        nft.transferFrom(msg.sender, address(0), _tokenId);

        // Issue refund
        payable(msg.sender).transfer(refundAmount);

        emit RefundIssued(_concertId, msg.sender, refundAmount);
    }

    function verifyTicket(
        uint256 _concertId,
        uint256 _tokenId,
        address _attendee
    )
        public
        view
        concertExists(_concertId)
        notCancelled(_concertId)
        returns (bool)
    {
        ConcertTicketNFT nft = ConcertTicketNFT(concertNFTs[_concertId]);
        return nft.ownerOf(_tokenId) == _attendee;
    }

    /**
     * @dev Get ticket class index for a specific token
     * @param _concertId The ID of the concert
     * @param _tokenId The ID of the ticket token
     * @return uint256 The ticket class index
     */
    function getTicketClassIndex(
        uint256 _concertId,
        uint256 _tokenId
    ) public view returns (uint256) {
        // Check if concert exists
        require(
            _concertId > 0 && _concertId <= _concertIds,
            "Concert does not exist"
        );
        require(concerts[_concertId].isActive, "Concert is not active");

        // Get ticket details
        TicketDetails memory details = ticketDetails[_concertId][_tokenId];
        require(details.isValid, "Invalid ticket");
        require(
            details.concertId == _concertId,
            "Ticket does not belong to this concert"
        );

        // Get concert and validate ticket class index
        Concert storage concert = concerts[_concertId];
        require(
            details.ticketClassIndex < concert.ticketClasses.length,
            "Invalid ticket class index"
        );

        return details.ticketClassIndex;
    }

    function getConcertTicketClasses(
        uint256 _concertId
    ) public view returns (TicketClass[] memory) {
        require(
            _concertId > 0 && _concertId <= _concertIds,
            "Concert does not exist"
        );
        return concerts[_concertId].ticketClasses;
    }

    /**
     * @dev Get ticket class details for a specific token
     * @param _concertId The ID of the concert
     * @param _tokenId The ID of the ticket token
     * @return TicketClass The ticket class details
     */
    function getTicketClass(
        uint256 _concertId,
        uint256 _tokenId
    ) public view returns (TicketClass memory) {
        uint256 classIndex = getTicketClassIndex(_concertId, _tokenId);
        return concerts[_concertId].ticketClasses[classIndex];
    }

    function generateTokenURI(
        uint256 _concertId,
        uint256 _ticketClassIndex,
        uint256 _ticketNumber
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://api.yourticketservice.com/metadata/",
                    toString(_concertId),
                    "/",
                    toString(_ticketClassIndex),
                    "/",
                    toString(_ticketNumber)
                )
            );
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // Emergency functions
    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }
}
