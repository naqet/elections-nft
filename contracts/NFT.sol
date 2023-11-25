// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Elections is ERC721, Ownable {
    uint128 public tokenCount;

    constructor() ERC721("Elections", "ELE") Ownable(msg.sender) {}

    function safeMint() public {
        require(balanceOf(msg.sender) < 1, "Only one NFT per user");
        uint128 tokenId = tokenCount;
        tokenCount++;
        _safeMint(msg.sender, tokenId);
    }
}
