// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Add the import statement for the KAROOTI Token contract
import "https://github.com/SirLibertino/contracts/blob/main/KAROOTI.sol";

contract KAROOTICreateNFT is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;
    address contractAddress;

    // Add a variable to store the contract address of the KAROOTI Token contract
    KAROOTI public karootiToken;

    // Modify the cost variable to use KAROOTI Tokens instead of ether
    uint256 public cost = 75 * 10**18;

    // Modify the constructor to accept the contract address of the KAROOTI Token contract as an input
    constructor(address marketContract, address karootiTokenAddress)
        ERC721("KAROOTIMarket", "WHYM")
    {
        contractAddress = marketContract;
        karootiToken = KAROOTI(karootiTokenAddress);
    }

    function mintNFT(string memory tokenURI)
        public
        payable
        nonReentrant
        returns (uint256)
    {
        // Check that the user has sent the required number of KAROOTI Tokens
        require(
            karootiToken.balanceOf(msg.sender) >= cost,
            "You do not have enough KAROOTI Tokens"
        );

        // Transfer the required number of KAROOTI Tokens to the contract
        karootiToken.transferFrom(msg.sender, address(this), cost);

        // Increment the token ID counter
        _tokenIds.increment();

        // Create the new NFT
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }

    function withdraw() public payable nonReentrant onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function withdrawAllKarooti() public payable nonReentrant onlyOwner {
        uint256 balance = karootiToken.balanceOf(address(this));
        require(balance > 0, "Insufficient balance");
        karootiToken.transfer(msg.sender, balance);
    }

    // Add a new method to return the list of NFTs
    function getNFTs() public view returns (uint256[] memory) {
        // Create a dynamic array to store the values
        uint256[] memory values = new uint256[](_tokenIds.current());

        // Iterate over the values and store them in the array
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            values[i] = i;
        }

        return values;
    }
}
