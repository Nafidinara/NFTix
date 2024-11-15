// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ConcertTicketNFT.sol";

contract NFTFactory is Ownable {
    event NFTCreated(address nftAddress, string name, string symbol);

    constructor() Ownable(msg.sender) {}

    function createNFT(
        string memory name,
        string memory symbol
    ) public onlyOwner returns (address) {
        ConcertTicketNFT newNFT = new ConcertTicketNFT(name, symbol);
        emit NFTCreated(address(newNFT), name, symbol);
        return address(newNFT);
    }
}
