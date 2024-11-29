// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ConcertTicketNFT is ERC721, ERC721URIStorage {
    uint256 private _tokenIds;
    string private _baseIPFSHash;

    mapping(uint256 => TicketMetadata) public ticketMetadata;

    struct TicketMetadata {
        uint256 concertId;
        uint256 classIndex;
        uint256 ticketNumber;
        string ipfsHash;
    }

    event MetadataUpdated(uint256 tokenId, string ipfsHash);

    constructor(
        string memory name,
        string memory symbol,
        string memory baseIPFSHash
    ) ERC721(name, symbol) {
        _baseIPFSHash = baseIPFSHash;
    }

    function safeMint(
        address to,
        uint256 concertId,
        uint256 classIndex,
        uint256 ticketNumber,
        string memory ipfsHash
    ) public returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _safeMint(to, newTokenId);

        // Store metadata
        ticketMetadata[newTokenId] = TicketMetadata({
            concertId: concertId,
            classIndex: classIndex,
            ticketNumber: ticketNumber,
            ipfsHash: ipfsHash
        });

        // Set token URI
        _setTokenURI(newTokenId, ipfsHash);

        emit MetadataUpdated(newTokenId, ipfsHash);

        return newTokenId;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return
            string(
                abi.encodePacked("ipfs://", ticketMetadata[tokenId].ipfsHash)
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
