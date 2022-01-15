// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract lowLevelBox is ERC721,IERC721Receiver,Ownable,Pausable {
    // Mapping from token id to position in the allTokens array

    using Address for address;
    using SafeMath for uint256;
    using Strings for uint256;

    string private baseURI;

    uint256[] private _boxIds;
    mapping(uint256 => uint256) private _TokenIndex;
    mapping(uint256 => bool) private _tokenExsits;
    address private _nftAddrss;


    //payment
    string public constant TOKEN_USDT = "USDT";
    mapping(string => address) private _tokenAddresses;

    
    //box 
    uint256 private _price;
    uint256 private _lastBoxid = 1;
    uint256 private _totalSupply;

    //time 
    uint256 private _startTime;
    uint256 private _endTime;

    //event
    event Buy(address customer ,uint256 tokenId,uint256 price,uint256 time);
    // event OpenBox(address account,uint256 tokenId,uint256 time);
    event StartTime(uint256 oldTime,uint256 newTime);
    event EndTime(uint256 oldTime,uint256 newTime);

    constructor(
        address nftAdress_,
        string memory name_,
        uint256 totalSupply_ ,
        string memory symbol_,
        string memory baseUri_,
        address usdtAddress_,
        uint256 startTime_,
        uint256 endTime_,
        uint256 price_
        )ERC721(name_,symbol_){

        require(nftAdress_ != address(0));
        require(totalSupply_>0);
        require(startTime_ >0 && endTime_ > startTime_,"invalid time");
        _totalSupply = totalSupply_;
        _nftAddrss = nftAdress_;
        _startTime = startTime_;
        _endTime = endTime_;
        baseURI = string(abi.encodePacked(baseUri_,symbol_, "/"));
        _tokenAddresses[TOKEN_USDT] = usdtAddress_;
        _price = price_;
    }

    function setBaseUri(string memory baseURI_)public onlyOwner{
        baseURI = baseURI_;
    }

    function tokenURI(uint256 tokenID)public view override returns(string memory){
        return string(abi.encodePacked(baseURI,tokenID.toString()));
    }

    function setPause() external onlyOwner whenNotPaused  {
        _pause();
    }

    function unsetPause() external onlyOwner whenPaused {
        _unpause();
    }

     // set start time
    function setStartTime(uint256 _time) public onlyOwner{
        require(_time > 0 && _time < _endTime, "invalid time");
        _startTime = _time;
        emit StartTime(_startTime, _time);
    }

    // set end time
    function setEndTime(uint256 _time) public onlyOwner{
        require(_time > _startTime, "invalid time");
        _endTime = _time;
        emit EndTime(_endTime, _time);
    }


    function setPrice(uint256 price_)external onlyOwner{
        _price = price_;
    }

    function setERC20Address(string calldata _tokenType,address _erc20Address) public onlyOwner {
        require(_tokenAddresses[_tokenType] == address(0),"ERC20 Contract Address Already exist");
        _tokenAddresses[_tokenType] = _erc20Address;
    } 


    function buyBox(string memory tokenName) external whenNotPaused returns (uint256) {
        //check totalsupply limit
        require(_lastBoxid<=_totalSupply,"it's sold out");
        require(block.timestamp>=_startTime && block.timestamp <= _endTime,"invalid time");
        //check tokenAddress
        address tokenAddr = _tokenAddresses[tokenName];
        require(tokenAddr != address(0),"Wrong addresses interaction");
        require(!_msgSender().isContract(),"invalid address");

        IERC20 _erc20Address = IERC20(tokenAddr);
    
        uint256 _amount = _erc20Address.allowance(msg.sender,address(this));
        require(_amount >= _price,"Not ennogh value");
        //transfer to this
        require(_erc20Address.transferFrom(msg.sender, address(this), _price),"Not Enough tokens Transfered");
        // mint box
        _safeMint(_msgSender(),_lastBoxid);
        emit Buy(_msgSender() ,_lastBoxid,_price,block.timestamp);
        return _lastBoxid++;
    }

    function openBox(uint256 tokenId) external whenNotPaused returns(uint256){
        require(block.timestamp>=_startTime && block.timestamp <= _endTime,"invalid time");
        //require tokenId
        require(_exists(tokenId),"box tokenId is not exists");
        //require tokenid owner msgSender()
        require(ownerOf(tokenId)==_msgSender());
        // get current nft amount
        uint256 nfts = _boxIds.length;
        // random nft TokenId
        uint256 nftIndex = _random() % nfts;

        uint256 nftTokenId = tokenByIndex(nftIndex);
        //burn box tokenId
        _burn(tokenId);
        // transfer nft to customer
        IERC721(_nftAddrss).safeTransferFrom(address(this),msg.sender,nftTokenId);
        _tokenExsits[nftTokenId] = false;
        _removeNftFromEnumeration(nftTokenId);
        return nftTokenId;
    } 




    function claimPayment(string memory tokenName_)external onlyOwner {
        address tokenAddr = _tokenAddresses[tokenName_];
        require(tokenAddr != address(0),"token not support");
        uint256 amount = IERC20(tokenAddr).balanceOf(address(this));
        if (amount >0){
            IERC20(tokenAddr).transfer(_msgSender(), amount);
        }   
    }

    function soldOut()public view returns(bool){
        return _lastBoxid >= _totalSupply;
    }

     function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        require(IERC721(_nftAddrss).ownerOf(tokenId) == address(this),"Not belong this address");
        require(!_exists(tokenId),"This id is already exist");
        _tokenExsits[tokenId] = true;
        _addNftToEnumeration(tokenId);
        return this.onERC721Received.selector;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addNftToEnumeration(uint256 tokenId) private {
        _TokenIndex[tokenId] = _boxIds.length;
        _boxIds.push(tokenId);
    }

    function _removeNftFromEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _boxIds.length - 1;
        uint256 tokenIndex = _TokenIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _boxIds[lastTokenIndex];

        _boxIds[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _TokenIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _TokenIndex[tokenId];
        _boxIds.pop();
    }

    // tokenid exists
    function _NftExists(uint256 tokenId) private view returns(bool) {
        return _tokenExsits[tokenId];
    }

    function RemainNfts() public view returns (uint256[] memory) {
        return _boxIds;
    }

    function _transferBackToNft(uint256 tokenId) private onlyOwner {
        require(_NftExists(tokenId),"this tokenId don't exist");
        require(IERC721(_nftAddrss).ownerOf(tokenId) == address(this),"Not belong this address");
        IERC721(_nftAddrss).safeTransferFrom(address(this),_nftAddrss,tokenId);
        //
        _tokenExsits[tokenId] = false;
        _removeNftFromEnumeration(tokenId);
    }

    function transferBatchToNft() public onlyOwner {
        require(block.timestamp > _endTime);
        for (uint256 i = 0; i < _boxIds.length; ++i) {
            uint256 _tokenId = tokenByIndex(i);
            _transferBackToNft(_tokenId);
        }

    }

    /**
     * @dev 
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < _boxIds.length, "ERC721Enumerable: global index out of bounds");
        return _boxIds[index];
    }

    // random func
    function _random() private view returns (uint256 rand) {
        uint256 blocknumber = block.number;
        uint256 random_gap = uint256(keccak256(abi.encodePacked(blockhash(blocknumber-1), msg.sender))) % 255;
        uint256 random_block = blocknumber - 1 - random_gap;
        bytes32 sha = keccak256(abi.encodePacked(blockhash(random_block),
        msg.sender,
        block.coinbase,
        block.difficulty));
        return uint256(sha);
    }
}