// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;
    mapping(uint256 => uint256) public tokenPrices;

    event TokenMinted(uint256 tokenId, address owner, string tokenURI);
    event TokenListed(uint256 tokenId, uint256 price);
    event TokenBought(uint256 tokenId, address buyer, uint256 price);

    constructor() ERC721("DigitalMarketplace", "DMP") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function mintNFT(string memory _tokenURI) public onlyOwner {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        tokenCounter++;

        emit TokenMinted(newTokenId, msg.sender, _tokenURI);
    }

    function listNFT(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "Not the token owner.");
        require(_price > 0, "Price must be greater than zero.");
        tokenPrices[_tokenId] = _price;

        emit TokenListed(_tokenId, _price);
    }

    function buyNFT(uint256 _tokenId) public payable {
        uint256 price = tokenPrices[_tokenId];
        require(price > 0, "This NFT is not for sale.");
        require(msg.value == price, "Incorrect payment amount.");

        address seller = ownerOf(_tokenId);
        _transfer(seller, msg.sender, _tokenId);
        payable(seller).transfer(msg.value);
        tokenPrices[_tokenId] = 0;

        emit TokenBought(_tokenId, msg.sender, price);
    }
}
