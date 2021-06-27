// SPDX-License-Identifier: MIT

//** Artify NFT Factory Interface Contract */
//** Author Alex Hong : Artify 2021.6 */

pragma solidity 0.6.12;

import "../libraries/IBEP20.sol";

interface ISphnFactory {
    event NewPool(uint256 poolID, uint256 date);
    event NewDepsoit(address wallet);
    event NewWithdrawl(address wallet);

    /** inhert functions for factory */
    function setMaxPoolCapacity(uint256 _maxPoolCapacity)
        external
        returns (bool);

    function setMaxInvestorNumber(uint256 nwMaxInvestorNumber)
        external
        returns (bool);

    function setArtifyToken(IBEP20 _token) external returns (bool);

    function getArtifyToken() external view returns (address);

    function getTotalToken(IBEP20 _token) external view returns (uint256);

    function addNftPool(uint256 _poolID, string calldata _poolName)
        external
        payable
        returns (bool);

    function joinNftPool(uint256 _poolID, string calldata _tokenURI)
        external
        payable
        returns (bool);

    function removeFromNftPool(uint256 _poolID) external payable returns (bool);
}
