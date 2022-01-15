// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket{

  function saveSellerInfo(uint256 _tokenId,uint256 _price,string calldata _nftType,string calldata _tokenType)
    external
    returns (bytes4); 
}
