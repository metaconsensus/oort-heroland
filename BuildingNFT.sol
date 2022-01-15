// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTMock.sol";
import "./IMarket.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BuildingNFT is NFTMock, IERC721Receiver {
    using Address for address;

    //Mapping from buildingType to  the building of buildingType all current count
    mapping(string => uint256) private buildingAllCounts;

    //Mapping from owner to the building of buildingType count
    mapping(address => mapping(string => uint256)) private playerBuildingCounts;

    // Mapping from buildingType to building max total supply
    mapping(string => uint256) private buildingMaxCounts;
    // Mapping from token ID to Building
    mapping(uint256 => Building) private buildings;

    /**
     * @dev the event of the game new a buildingType
     */
    event NewBuildingType(string indexed buildingType);

    /**
     * @dev the conscrut of Building
     */
    struct Building {
        // the buildingType
        string buildingType;
    }

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
        buildingMaxCounts["Logging yard"] = 500000;
        buildingMaxCounts["Quarry"] = 500000;
        buildingMaxCounts["Iron mine"] = 500000;
        buildingMaxCounts["Wheat field"] = 500000;
    }

     /**
     * @dev Add a new type building
     * @param _buildingType the building type
     * @param _count  the building's max count
     */
    function newBuildingType(
        string memory _buildingType,
        uint256 _count
    ) external onlyOwner {
        require(buildingMaxCounts[_buildingType] == 0, "This land type already exist");
        buildingMaxCounts[_buildingType] = _count;
        emit NewBuildingType(_buildingType);
    }

    /**
     * @dev Throws if the buildingTye don't exist or the type of building out of counts
     * @param _buildingType the building type
     */
    modifier canMintBuilding(string memory _buildingType) {
        require(buildingMaxCounts[_buildingType] != 0, "This building type don't exist");
        require(buildingAllCounts[_buildingType] < buildingMaxCounts[_buildingType], "Out of the building type's max count");
        _;
    }

    /**
     * @dev create a new building
     * @param _to who has the nft
     * @param _tokenId NFTid
     * @param _uri String representing RFC 3986 URI.
     * @param _buildingType the building type
     */
    function mint(
        address _to,
        uint256 _tokenId,
        string memory _uri,
        string memory _buildingType
    ) public canMintBuilding(_buildingType) onlyOwner {
        super._safeMint(_to, _tokenId);
        super._setTokenURI(_tokenId, _uri);
        buildingAllCounts[_buildingType] += 1;
        playerBuildingCounts[_to][_buildingType] += 1;
        buildings[_tokenId] = Building({buildingType: _buildingType});
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        string memory _buildingType = getBuildingType(tokenId);
        buildingAllCounts[_buildingType] -= 1;
        address _owner = ERC721.ownerOf(tokenId);
        playerBuildingCounts[_owner][_buildingType] -= 1;
        delete buildings[tokenId];
        _burn(tokenId);
    }

    /**
     * @dev the player withdraw a building to his address. if the _tokenId not mint ,mint a nft to his address.
     * else tranfer the nftid from this contract address to his address.
     */
    function withDraw(
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        string calldata _buildingType
    ) public onlyOwner {
        if (_exists(_tokenId)) {
            require(ownerOf(_tokenId) == address(this), "Not belong this address");
            this.safeTransferFrom(address(this), _to, _tokenId);
        } else {
            mint(_to, _tokenId, _uri, _buildingType);
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
            bytes4 retval = IMarket(_approved).saveSellerInfo(_tokenId, _price, "BUILDING", _tokenType);
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

    function getBuildingType(uint256 _tokenId) public view returns (string memory) {
        return buildings[_tokenId].buildingType;
    }

    function getBuildingAllCount(string calldata _buildingType) external view returns (uint256) {
        require(buildingMaxCounts[_buildingType] != 0, "This building type don't exist");
        return buildingAllCounts[_buildingType];
    }

    function getBuildingMaxCount(string calldata _buildingType) external view returns (uint256) {
        require(buildingMaxCounts[_buildingType] != 0, "This building type don't exist");
        return buildingMaxCounts[_buildingType];
    }

    function getAddressBuildingCount(address _address, string calldata _buildingType) external view returns (uint256) {
        require(buildingMaxCounts[_buildingType] != 0, "This building type don't exist");
        return playerBuildingCounts[_address][_buildingType];
    }
}
