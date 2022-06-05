// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

/// @custom:security-contact enokslaboratory@gmail.com
contract TheFreshestKids is ERC721, ERC721Enumerable, Pausable, Ownable {

    //************************************//
    //****** 1. PROPERTY VARIABLES *******//
    //************************************//
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public MINT_PRICE = 0.05 ether;
    uint256 public MAX_SUPPLY;
    bool public IS_MINT_ENABLED;
    mapping(address => uint256) public MINTED_AMOUNT;


    //************************************//
    //*********** 2. SVG CODE ************//
    //************************************//
    // baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // Three arrays, each with their own theme of random words.
    string[] firstWords = ["WILDEST", "COOLEST", "FRESHEST", "DOPEST", "CLEANEST", "QUICKEST", "BADDEST", "WISEST", "SPONTANEOUS"];
    string[] secondWords = ["GRAFF", "BREAK", "BEAT_BOX", "TRIBE", "STYLE", "FREESTYLE", "DJ", "MCEE", "GET_DOWN"];
    string[] thirdWords = ["HEAD", "BOY", "KID", "OG", "MASTER", "LEGEND", "CHARACTER", "BROTHER", "FATHER"];


    //************************************//
    //******* 3. LIFECYCLE METHODS *******//
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


    //****** Randomly pick a word from each array *******//
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }


    //*************************************//
    //******* 4. PAUSABLE FUNCTIONS *******//
    //*************************************//
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }


    //************************************//
    //******* 5. MINTING FUNCTIONS *******//
    //************************************//
    function safeMint(address to) public payable {
        // check if minting is enabled
        require(IS_MINT_ENABLED, "Minting disabled");

        // check if ether value is correct
        require(totalSupply() < MAX_SUPPLY, "Can't mint anymore tokens");

        // check if wallet does not exceed max per wallet
        require(MINTED_AMOUNT[to] < 8, "Exceeds max per wallet");

        // check if ether value is correct
        require(msg.value >= MINT_PRICE, "Not enough ether sent");
    
        uint256 tokenId = _tokenIdCounter.current();


        //******* Create SVG from Random Words *******//
        //********************************************//
        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(tokenId);
        string memory second = pickRandomSecondWord(tokenId);
        string memory third = pickRandomThirdWord(tokenId);

        // Concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, first, second, third, "</text></svg>"));
        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");


        MINTED_AMOUNT[to]++;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        console.log("An NFT w/ ID %s has been minted to %s", tokenId, to);
    }


    //************************************//
    //******** 6. OTHER FUNCTIONS ********//
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