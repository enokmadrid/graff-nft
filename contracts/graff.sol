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


    //************************************//
    //******* 2. LIFECYCLE METHODS *******//
    //************************************//
    constructor() ERC721("The Freshest Kids", "TFK") {}

    function _baseURI() internal pure override returns (string memory) {
        return "http://thefreshestkids.eth";
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
    function safeMint(address to) public {
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