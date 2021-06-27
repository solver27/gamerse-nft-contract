// SPDX-License-Identifier: MIT

//** Artify NFT Pool Contract */
//** Author Alex Hong : Aritfy 2021.6 */

pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/IBEP20.sol";
import "./libraries/SafeBEP20.sol";
import "./interface/IArtifyFactory.sol";
import "./interface/IArtifyNifty.sol";

contract ArtifyNftPool is IArtifyFactory, Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct InvestorInfo {
        uint256 joinDate;
        address wallet;
        bool active;
    }

    struct PoolInfo {
        uint256 poolID;
        string poolName;
        uint256 investorNumber;
        uint256 createDate;
        bool active;
        mapping(address => InvestorInfo) investorList;
    }

    mapping(uint256 => PoolInfo) public artifyPools;
    mapping(address => uint256) public nftIndicies;
    IBEP20 public _artifyToken;
    address public _nftAddress;
    uint256 public _investCap;
    uint256 public _maxInvestorNumber;
    uint256 public _maxPoolCapacity;

    constructor(address _nft) public {
        _investCap = 1e20;
        _maxPoolCapacity = 2;
        _maxInvestorNumber = 20;
        _nftAddress = _nft;
    }

    modifier isPool(uint256 _poolID) {
        require(artifyPools[_poolID].active, "Pool is not existing");
        _;
    }

    function setArtifyToken(IBEP20 _token)
        external
        override
        onlyOwner
        returns (bool)
    {
        _artifyToken = _token;
        return true;
    }

    function getArtifyToken() external view override returns (address) {
        return address(_artifyToken);
    }

    function getTotalToken(IBEP20 _token)
        external
        view
        override
        returns (uint256)
    {
        return _token.balanceOf(address(this));
    }

    function setMaxPoolCapacity(uint256 nwMaxPoolCapacity)
        external
        override
        returns (bool)
    {
        _maxPoolCapacity = nwMaxPoolCapacity;
        return true;
    }

    function setMaxInvestorNumber(uint256 nwMaxInvestorNumber)
        external
        override
        returns (bool)
    {
        _maxInvestorNumber = nwMaxInvestorNumber;
        return true;
    }

    function addNftPool(uint256 _poolID, string calldata _poolName)
        external
        payable
        override
        onlyOwner
        returns (bool)
    {
        require(_maxPoolCapacity > 0, "Max pool capacity reached");
        require(!artifyPools[_poolID].active, "Pool already exist");
        PoolInfo memory tpPool = PoolInfo({
            poolID: _poolID,
            poolName: _poolName,
            investorNumber: 0,
            createDate: block.timestamp,
            active: true
        });
        artifyPools[_poolID] = tpPool;

        _maxPoolCapacity -= 1;
        emit NewPool(_poolID, block.timestamp);
        return true;
    }

    function joinNftPool(uint256 _poolID, string calldata _tokenURI)
        external
        payable
        override
        isPool(_poolID)
        returns (bool)
    {
        require(
            _artifyToken.balanceOf(address(msg.sender)) > _investCap,
            "need to have enough Artify"
        );
        require(
            artifyPools[_poolID].investorNumber < _maxInvestorNumber,
            "pool is full"
        );
        require(
            artifyPools[_poolID].investorList[msg.sender].wallet != msg.sender,
            "user already joinned for this pool"
        );

        artifyPools[_poolID].investorList[msg.sender].joinDate = block
        .timestamp;
        artifyPools[_poolID].investorList[msg.sender].wallet = msg.sender;
        artifyPools[_poolID].investorList[msg.sender].active = true;
        artifyPools[_poolID].investorNumber++;
        _artifyToken.safeTransferFrom(msg.sender, address(this), _investCap);
        //need to update for who will have
        uint256 tokenID = IArtifyNifty(_nftAddress).mint(msg.sender, _tokenURI);
        nftIndicies[msg.sender] = tokenID;

        emit NewDepsoit(msg.sender);
        return true;
    }

    function removeFromNftPool(uint256 _poolID)
        external
        payable
        override
        isPool(_poolID)
        returns (bool)
    {
        require(
            artifyPools[_poolID].investorList[msg.sender].wallet ==
                msg.sender &&
                artifyPools[_poolID].investorList[msg.sender].active,
            "user is not existing in the pool"
        );
        require(nftIndicies[msg.sender] > 0, "need to be owner");
        require(
            IArtifyNifty(_nftAddress).exists(nftIndicies[msg.sender]),
            "NFT not available"
        );
        require(
            IArtifyNifty(_nftAddress).ownerOf(nftIndicies[msg.sender]) ==
                msg.sender,
            "NFT should be on wallet"
        );
        artifyPools[_poolID].investorList[msg.sender].active = false;
        artifyPools[_poolID].investorList[msg.sender].wallet = address(0);
        artifyPools[_poolID].investorNumber--;
        _artifyToken.safeTransfer(msg.sender, _investCap);
        IArtifyNifty(_nftAddress).burn(nftIndicies[msg.sender]);
        nftIndicies[msg.sender] = 0;
        emit NewWithdrawl(msg.sender);
    }
}
