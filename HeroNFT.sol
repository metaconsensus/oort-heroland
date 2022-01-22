// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTMock.sol";
import "./IMarket.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract HeroNFT is NFTMock,IERC721Receiver {

    using Address for address;
    /**
     * @dev a mapping from the rarity to the class of hero's current count
     */
    mapping(string => mapping(string => uint256)) private heroCount;

    /**
     * @dev a mapping from the rarity to the class of hero's maxCount
     */
    mapping(string => mapping(string => uint256)) private heroMaxCount;

    /**
     * @dev a mapping from owner to the class of hero's count
     */
    mapping(address => mapping(string => uint256)) private addressHeroClassCount;

    /**
     * @dev a mapping from owner to the rarity of hero's count
     */
    mapping(address => mapping(string => uint256)) private addressHeroRarityCount;

    /**
     * @dev the event of the game new a hero class
     */
    event NewHeroClass(string indexed rarity, string indexed class);

    /**
     * @dev from tokenid to hero
     */
    mapping(uint256 => Hero) private heros;

    /**
     * @dev Magic value of a smart contract that can receive NFT.
     * Equal to: .
     */
    // bytes4 internal constant MAGIC_ON_DEPOSIT = bytes4(keccak256("depositToken(uint256,uint256)"));

    string constant Exceeded = "Out of the hero class's max count";
    string constant No_Hero = "This Hero class don't exist";
    string constant Has_Hero = "This hero class already exist";

    /**
     * @dev Guarantees that can mint a new NFT ,it don't exceed the class of Hero's max count
     * 
     */
    modifier canMintHero(string memory rarity, string memory class) {
        require(heroMaxCount[rarity][class] != 0, No_Hero);
        require(heroCount[rarity][class] < heroMaxCount[rarity][class], Exceeded);
        _;
    }

    /**
     * @dev Contract constructor.
     * @param _name A descriptive name for a collection of NFTs.
     * @param _symbol An abbreviated name for NFTokens.
     */
    constructor(string memory _name, string memory _symbol,string memory _uri) NFTMock(_name, _symbol) {
        setBaseURI(_uri);
        _setHeroInfo("Diamond", "Xiang Yu", 100);
        // _setHeroInfo("Diamond", "Monkey King", 100);
        // _setHeroInfo("Diamond", "Caesar", 100);
        // _setHeroInfo("Diamond", "Pangu", 100);
        // _setHeroInfo("Diamond", "Rambo", 100);
        // _setHeroInfo("Diamond", "Leonidas", 100);
        // _setHeroInfo("Diamond", "Osiris", 100);
        // _setHeroInfo("Diamond", "Alexandria", 100);
        // _setHeroInfo("Diamond", "Cap of invisibility", 100);
        // _setHeroInfo("Diamond", "Prometheus", 100);
        // _setHeroInfo("Golden", "Apollo", 300);
        // _setHeroInfo("Golden", "King Arthur", 300);
        // _setHeroInfo("Golden", "From wikipedia", 300);
        // _setHeroInfo("Golden", "Aristotle", 300);
        // _setHeroInfo("Golden", "Odin", 300);
        // _setHeroInfo("Golden", "Nepoleon", 300);
        // _setHeroInfo("Golden", "Athena", 300);
        // _setHeroInfo("Golden", "Godefroy de Bouillon", 300);
        // _setHeroInfo("Golden", "Mohist Canon", 300);
        // _setHeroInfo("Golden", "Newton", 300);
        // _setHeroInfo("Golden", "Asoka", 300);
        // _setHeroInfo("Golden", "Cupid", 300);
        // _setHeroInfo("Golden", "Gandalf", 300);
        // _setHeroInfo("Golden", "Oda Nobunaga", 300);
        // _setHeroInfo("Golden", "Zeus", 300);
        // _setHeroInfo("Golden", "Sima Yi", 300);
        // _setHeroInfo("Golden", "Hella", 300);
        // _setHeroInfo("Golden", "Genghis Khan", 300);
        // _setHeroInfo("Golden", "SunTzu", 300);
        // _setHeroInfo("Golden", "Supreme Lord Lao Zi", 300);
        // _setHeroInfo("Golden", "Gaia", 300);
        // _setHeroInfo("Golden", "Robin Hood", 300);
        // _setHeroInfo("Golden", "Medusa", 300);
        // _setHeroInfo("Golden", "Zheng Chenggong", 300);
        // _setHeroInfo("Golden", "Gumiho", 300);
        // _setHeroInfo("Golden", "Takead", 300);
        // _setHeroInfo("Golden", "Charles the Great", 300);
        // _setHeroInfo("Golden", "Pooky", 300);
        // _setHeroInfo("Golden", "Honda tadakatsu", 300);
        // _setHeroInfo("Golden", "Siva", 300);
        // _setHeroInfo("Silver", "Xing Tian", 6000);
        // _setHeroInfo("Silver", "The Lord of Virtue", 6000);
        // _setHeroInfo("Silver", "Emperor Taizong of Tang", 6000);
        // _setHeroInfo("Silver", "Atira", 6000);
        // _setHeroInfo("Silver", "LiBai", 6000);
        // _setHeroInfo("Silver", "Lian Po", 6000);
        // _setHeroInfo("Silver", "Yue Fei", 6000);
        // _setHeroInfo("Silver", "Gandhi", 6000);
        // _setHeroInfo("Silver", "First Emperor of Qin", 6000);
        // _setHeroInfo("Silver", "Einstein", 6000);
        // _setHeroInfo("Silver", "Hannibal Barca", 6000);
        // _setHeroInfo("Silver", "Uesugi Kenshin", 6000);
        // _setHeroInfo("Silver", "Frederick the Great", 6000);
        // _setHeroInfo("Silver", "Alice", 6000);
        // _setHeroInfo("Silver", "Montezuma", 6000);
        // _setHeroInfo("Silver", "the Emperor Taizu of Ming", 6000);
        // _setHeroInfo("Silver", "Toyotomi Hideyoshi", 6000);
        // _setHeroInfo("Silver", "Washington", 6000);
        // _setHeroInfo("Silver", "Hades", 6000);
        // _setHeroInfo("Silver", "Rommelwas", 6000);
        // _setHeroInfo("Silver", "Archimedes", 6000);
        // _setHeroInfo("Silver", "Benjamin", 6000);
        // _setHeroInfo("Silver", "Karl", 6000);
        // _setHeroInfo("Silver", "Gary", 6000);
        // _setHeroInfo("Silver", "George", 6000);
        // _setHeroInfo("Silver", "Metis", 6000);
        // _setHeroInfo("Silver", "Johansson", 6000);
        // _setHeroInfo("Silver", "Duke", 6000);
        // _setHeroInfo("Silver", "Stanly", 6000);
        // _setHeroInfo("Silver", "Norman", 6000);
        // _setHeroInfo("Bronze", "Adam", 30000);
        // _setHeroInfo("Bronze", "Exakoustidis", 30000);
        // _setHeroInfo("Bronze", "Christian", 30000);
        // _setHeroInfo("Bronze", "Colin", 30000);
        // _setHeroInfo("Bronze", "Carol", 30000);
        // _setHeroInfo("Bronze", "Dani", 30000);
        // _setHeroInfo("Bronze", "Cindy", 30000);
        // _setHeroInfo("Bronze", "Corrine", 30000);
        // _setHeroInfo("Bronze", "Sousse", 30000);
        // _setHeroInfo("Bronze", "Douglas", 30000);
        // _setHeroInfo("Bronze", "Jason", 30000);
        // _setHeroInfo("Bronze", "Kaka", 30000);
        // _setHeroInfo("Bronze", "Lian Tian", 30000);
        // _setHeroInfo("Bronze", "Shi Peng", 30000);
        // _setHeroInfo("Bronze", "Ge Deming", 30000);
        // _setHeroInfo("Bronze", "Daisy", 30000);
        // _setHeroInfo("Bronze", "Keri", 30000);
        // _setHeroInfo("Bronze", "Modreza", 30000);
        // _setHeroInfo("Bronze", "Sui haocang", 30000);
        // _setHeroInfo("Bronze", "Jonathan", 30000);
        // _setHeroInfo("Iron", "Estelle", 60000);
        // _setHeroInfo("Iron", "Jakob", 60000);
        // _setHeroInfo("Iron", "Katrina", 60000);
        // _setHeroInfo("Iron", "King Mark", 60000);
        // _setHeroInfo("Iron", "Stuart", 60000);
        // _setHeroInfo("Iron", "Melinda", 60000);
        // _setHeroInfo("Iron", "Alberta", 60000);
        // _setHeroInfo("Iron", "racer", 60000);
        // _setHeroInfo("Iron", "Sophia", 60000);
        // _setHeroInfo("Iron", "Daenerys", 60000);
        // _setHeroInfo("Iron", "Aimar", 60000);
        // _setHeroInfo("Iron", "Joseph", 60000);
        // _setHeroInfo("Iron", "Agatha", 60000);
        // _setHeroInfo("Iron", "Baird", 60000);
        // _setHeroInfo("Iron", "Aubrey", 60000);
        // _setHeroInfo("Iron", "Narzo", 60000);
        // _setHeroInfo("Iron", "James", 60000);
        // _setHeroInfo("Iron", "Louis", 60000);
        // _setHeroInfo("Iron", "Clifford", 60000);
        // _setHeroInfo("Iron", "Martin", 60000);
    }

    /**
     * @dev Add a new rarity class Hero
     * @param _rarity the rarity of new Hero
     * @param _class the calss of new Hero
     * @param _count  the hero's max count
     */
    function newHeroClass(
        string memory _rarity,
        string memory _class,
        uint256 _count
    ) external onlyOwner {
        require(heroMaxCount[_rarity][_class] == 0, Has_Hero);
        _setHeroInfo(_rarity, _class, _count);
        emit NewHeroClass(_rarity, _class);
    }

    function _setHeroInfo(
        string memory _rarity,
        string memory _class,
        uint256 _count
    ) private {
        heroMaxCount[_rarity][_class] = _count;
    }

    /**
     * @dev create a hero Nft
     * @param _to who has the nft
     * @param _tokenId NFTid
     * @param _uri String representing RFC 3986 URI.
     */
    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        string calldata _rarity,
        string calldata _class
    ) public canMintHero(_rarity, _class) onlyOwner {
        super._safeMint(_to, _tokenId);
        super._setTokenURI(_tokenId, _uri);
        heroCount[_rarity][_class] +=  1;
        addressHeroRarityCount[_to][_rarity] +=  1;
        addressHeroClassCount[_to][_class] +=  1;
        heros[_tokenId] = Hero({rarity: _rarity, class: _class});
    }

    /**
     * @dev the player withdraw a hero to his address. if the _tokenId not mint ,mint a nft to his address.
     * else tranfer the nftid from this contract address to his address.
     */
    function withDraw( 
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        string calldata _rarity,
        string calldata _class
    ) public canMintHero(_rarity, _class) onlyOwner {
        if(_exists(_tokenId)) {
            require(ownerOf(_tokenId) == address(this),"Not belong this address");
            this.safeTransferFrom(address(this),_to,_tokenId);
        } else {
            mint(_to,_tokenId,_uri,_rarity,_class);
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
            bytes4 retval = IMarket(_approved).saveSellerInfo(_tokenId, _price,"HERO", _tokenType);
            require(retval == MAGIC_ON_DEPOSIT, "Not deposit contract");
        }
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        string memory _rarity = this.getHeroRarity(tokenId);
        string memory _class = this.getHeroClass(tokenId);
        heroCount[_rarity][_class] -= 1;
        address _to = ERC721.ownerOf(tokenId);
        addressHeroRarityCount[_to][_rarity] -=  1;
        addressHeroClassCount[_to][_class] -=  1;
        delete heros[tokenId];
        _burn(tokenId);
    }

    /**
     * @dev A struct of Hero
     */
    struct Hero {
        // The class of Hero. eg. N1 N2 N3 R1 R2 R3 SR1 SR2 SSR1
        string rarity;
        string class;
    }

    function getHeroAllCount(string calldata _rarity, string calldata _class) external view returns (uint256) {
        require(heroMaxCount[_rarity][_class] != 0, No_Hero);
        return heroCount[_rarity][_class];
    }

    function getHeroMaxCount(string calldata _rarity, string calldata _class) external view returns (uint256) {
        require(heroMaxCount[_rarity][_class] != 0, No_Hero);
        return heroMaxCount[_rarity][_class];
    }

    /**
     * @dev from the tokenid get the hero's class
     */
    function getHeroClass(uint256 _tokenId) external view returns (string memory) {
        return heros[_tokenId].class;
    }

    /**
     * @dev from the tokenid get the hero's rarity
     */
    function getHeroRarity(uint256 _tokenId) external view returns (string memory) {
        return heros[_tokenId].rarity;
    }

    /**
     * @dev Get the number of class of the heroes owned by the address
     */
    function getAddressHeroClassCount(address _fromAddress, string memory _class) public view returns (uint256) {
        return addressHeroClassCount[_fromAddress][_class];
    }

    /**
     * @dev Get the number of rarity of the heroes owned by the address
     */
    function getAddressHeroRarityCount(address _fromAddress, string memory _rarity) public view returns (uint256) {
        return addressHeroRarityCount[_fromAddress][_rarity];
    }

    

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function tokenURIBatch(uint256[] memory tokenIds) public view  returns(string[] memory){
        string[] memory batchUris = new string[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            batchUris[i] = tokenURI(tokenIds[i]);
        }
        return batchUris;
    }
}
