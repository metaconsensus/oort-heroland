// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTMock.sol";
import "./IMarket.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract LandNFT is NFTMock, IERC721Receiver {
    using Address for address;

    //Mapping from landType to  the land of landType all current count
    mapping(string => uint256) private landAllCounts;

    //Mapping from owner to the land of landType count
    mapping(address => mapping(string => uint256)) private playerLandCounts;

    // Mapping from landType to land max total supply
    mapping(string => uint256) private landMaxCounts;
    // Mapping from token ID to Land
    mapping(uint256 => Land) private lands;

    /**
     * @dev the conscrut of Land
     */
    struct Land {
        // the landType
        string landType;
    }

    /**
     * @dev the event of the game new a landType
     */
    event NewLandType(string indexed landType);

    /**
     * @dev Contract constructor.
     * @param _name A descriptive name for a collection of NFTs.
     * @param _symbol An abbreviated name for NFTokens.
     * @param _uri The base uri
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) NFTMock(_name, _symbol) {
        setBaseURI(_uri);
        landMaxCounts["Diamond Land"] = 100;
        landMaxCounts["Golden Land"] = 300;
        landMaxCounts["Silver Land"] = 500;
        landMaxCounts["Bronze Land"] = 3196;
    }

    /**
     * @dev Add a new type land
     * @param _landType the land type
     * @param _count  the land's max count
     */
    function newLandType(
        string memory _landType,
        uint256 _count
    ) external onlyOwner {
        require(landMaxCounts[_landType] == 0, "This land type already exist");
       landMaxCounts[_landType] = _count;
        emit NewLandType(_landType);
    }


    /**
     * @dev Throws if the landTye don't exist or the type of land out of counts
     * @param _landType the land type
     */
    modifier canMintLand(string memory _landType) {
        require(landMaxCounts[_landType] != 0, "This land type don't exist");
        require(landAllCounts[_landType] < landMaxCounts[_landType], "Out of the land type's max count");
        _;
    }

    /**
     * @dev create a new land
     * @param _to who has the nft
     * @param _tokenId NFTid
     * @param _uri String representing RFC 3986 URI.
     * @param _landType the land type
     */
    function mint(
        address _to,
        uint256 _tokenId,
        string memory _uri,
        string memory _landType
    ) public canMintLand(_landType) onlyOwner {
        super._safeMint(_to, _tokenId);
        super._setTokenURI(_tokenId, _uri);
        landAllCounts[_landType] += 1;
        playerLandCounts[_to][_landType] += 1;
        lands[_tokenId] = Land({landType: _landType});
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        string memory _landType = getLandType(tokenId);
        landAllCounts[_landType] -= 1;
        address _owner = ERC721.ownerOf(tokenId);
        playerLandCounts[_owner][_landType] -= 1;
        delete lands[tokenId];
        _burn(tokenId);
    }

    /**
     * @dev the player withdraw a land to his address. if the _tokenId not mint ,mint a nft to his address.
     * else tranfer the nftid from this contract address to his address.
     */
    function withDraw(
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        string calldata _landType
    ) public onlyOwner {
        if (_exists(_tokenId)) {
            require(ownerOf(_tokenId) == address(this), "Not belong this address");
            this.safeTransferFrom(address(this), _to, _tokenId);
        } else {
            mint(_to, _tokenId, _uri, _landType);
        }
    }

    bytes4 internal constant MAGIC_ON_DEPOSIT = bytes4(keccak256("saveSellerInfo(uint256,uint256,string,string)"));

    function approvalTransaction(
        address _approved,
        uint256 _tokenId,
        uint256 _price,
        string calldata _tokenType
    ) external {
        approve(_approved, _tokenId);
        if (_approved.isContract()) {
            bytes4 retval = IMarket(_approved).saveSellerInfo(_tokenId, _price, "LAND", _tokenType);
            require(retval == MAGIC_ON_DEPOSIT, "Not deposit contract");
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function tokenURIBatch(uint256[] memory tokenIds) public view returns (string[] memory) {
        string[] memory batchUris = new string[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            batchUris[i] = tokenURI(tokenIds[i]);
        }
        return batchUris;
    }

    function getLandType(uint256 _tokenId) public view returns (string memory) {
        return lands[_tokenId].landType;
    }

    function getLandAllCount(string calldata _landType) external view returns (uint256) {
        require(landMaxCounts[_landType] != 0, "This land type don't exist");
        return landAllCounts[_landType];
    }

    function getLandMaxCount(string calldata _landType) external view returns (uint256) {
        require(landMaxCounts[_landType] != 0, "This land type don't exist");
        return landMaxCounts[_landType];
    }

    function getAddressLandCount(address _address, string calldata _landType) external view returns (uint256) {
        require(landMaxCounts[_landType] != 0, "This land type don't exist");
        return playerLandCounts[_address][_landType];
    }
}
