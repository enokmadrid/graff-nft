// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact enokslaboratory@gmail.com
contract TheFreshestKids is ERC721, ERC721Enumerable, Pausable, Ownable {

    //************************************//
    //*******1. PROPERTY VARIABLES *******//
    //************************************//
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public MINT_PRICE = 0.05 ether;
    uint256 public MAX_SUPPLY;
    bool public IS_MINT_ENABLED;
    mapping(address => uint256) public MINTED_WALLETS;


    //************************************//
    //******* 2. LIFECYCLE METHODS *******//
    //************************************//
    constructor() ERC721("The Freshest Kids", "TFK") {
        _tokenIdCounter.increment(); // Start token ID at 1.
    }
    
    function _baseURI() internal pure override returns (string memory) {
        return "http://thefreshestkids.eth";
    }

    function setMaxSupply(uint256 maxSupply_) external onlyOwner {
        MAX_SUPPLY = maxSupply_;
    }

    function toggleIsMintEnabled() external onlyOwner {
        IS_MINT_ENABLED = !IS_MINT_ENABLED;
    }

    function withdraw() public onlyOwner() {
        require(address(this).balance > 0, "Balance is zero.");
        payable(owner()).transfer(address(this).balance);
    }


    //*************************************//
    //******* 3. PAUSABLE FUNCTIONS *******//
    //*************************************//
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }


    //************************************//
    //******* 4. MINTING FUNCTIONS *******//
    //************************************//
    function safeMint(address to) public payable {
        // check if minting is enabled
        require(IS_MINT_ENABLED, "Minting disabled");

        // check if ether value is correct
        require(totalSupply() < MAX_SUPPLY, "Can't mint anymore tokens");

        // check if wallet does not exceed max per wallet
        require(MINTED_WALLETS[to] < 8, "Exceeds max per wallet");

        // check if ether value is correct
        require(to >= MINT_PRICE, "Not enough ether sent");

        MINTED_WALLETS[msg.sender]++;

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }


    //************************************//
    //******** 5. OTHER FUNCTIONS ********//
    //************************************//
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}