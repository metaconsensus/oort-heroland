// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMock is ERC721URIStorage,ERC721Pausable,Ownable {
    string private _baseTokenURI;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721,ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    } 

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC721,ERC721URIStorage) {
        super._burn(tokenId);
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory newBaseTokenURI) public onlyOwner{
        _baseTokenURI = newBaseTokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721,ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    
}