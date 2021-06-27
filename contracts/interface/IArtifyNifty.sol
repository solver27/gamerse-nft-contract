// SPDX-License-Identifier: MIT

//** Artify ERC721 Interface Contract */
//** Author Alex Hong : Artify 2021.6 */

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IArtifyNifty is IERC721 {
    using SafeMath for uint256;

    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );

    function creators(uint256 tokenId) external view returns (address);

    function primarySalePrice(uint256 tokenId) external view returns (uint256);

    function mint(address _beneficiary, string calldata _tokenUri)
        external
        returns (uint256);

    function burn(uint256 _tokenId) external;

    function exists(uint256 _tokenId) external returns (bool);

    function isApproved(uint256 _tokenId, address _operator) external;
}
