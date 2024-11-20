// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ConcertTicketNFT.sol";

contract NFTFactory is Ownable {
    // Event for when a new NFT contract is created
    event NFTCreated(
        address nftAddress,
        string name,
        string symbol,
        string baseIPFSHash
    );

    // Mapping to store created NFT contracts
    mapping(address => bool) public isNFTContract;

    // Array to store all created NFT addresses
    address[] public allNFTs;

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Creates a new NFT contract for a concert
     * @param name Name of the NFT collection
     * @param symbol Symbol of the NFT collection
     * @param baseIPFSHash Base IPFS hash for the collection metadata
     * @return address Address of the newly created NFT contract
     */
    function createNFT(
        string memory name,
        string memory symbol,
        string memory baseIPFSHash
    ) public onlyOwner returns (address) {
        // Create new NFT contract with IPFS support
        ConcertTicketNFT newNFT = new ConcertTicketNFT(
            name,
            symbol,
            baseIPFSHash
        );

        // Store the contract address
        address nftAddress = address(newNFT);
        isNFTContract[nftAddress] = true;
        allNFTs.push(nftAddress);

        // Emit creation event
        emit NFTCreated(nftAddress, name, symbol, baseIPFSHash);

        return nftAddress;
    }

    /**
     * @dev Returns the number of NFT contracts created
     */
    function getNFTCount() public view returns (uint256) {
        return allNFTs.length;
    }

    /**
     * @dev Verifies if an address is a created NFT contract
     * @param nftAddress Address to verify
     */
    function verifyNFTContract(address nftAddress) public view returns (bool) {
        return isNFTContract[nftAddress];
    }

    /**
     * @dev Get all created NFT contracts
     * @return Array of NFT contract addresses
     */
    function getAllNFTs() public view returns (address[] memory) {
        return allNFTs;
    }

    /**
     * @dev Get NFT contracts within a range
     * @param startIndex Start index of the range
     * @param endIndex End index of the range
     * @return Array of NFT contract addresses within the specified range
     */
    function getNFTsInRange(
        uint256 startIndex,
        uint256 endIndex
    ) public view returns (address[] memory) {
        require(startIndex < endIndex, "Invalid range");
        require(endIndex < allNFTs.length, "End index out of bounds");

        uint256 length = endIndex - startIndex + 1;
        address[] memory nfts = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            nfts[i] = allNFTs[startIndex + i];
        }

        return nfts;
    }
}
