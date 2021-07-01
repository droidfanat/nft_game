// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IBalancesLikeERC1155
{
    event TransferSingle(uint256 indexed tokenIdFrom, uint256 indexed tokenIdTo, uint256 key, uint256 value);

    function burn(uint256 tokenId) external ;
    function mint(address to, uint256[8] memory keys, uint256[8] memory amounts) external  returns (uint256);

    function get(uint256 tokenId, uint256 key) view external  returns(uint256 balance);
    function getListBalancesForSingleId(uint256 tokenId, uint256[] memory keys) view external  returns (uint256[] memory);
    //function getListBalancesForManyIds(uint256[] memory tokenIds, uint256[] memory keys) view external  returns (uint256[][] memory);

    function set(uint256 tokenId, uint256 key, uint256 value) external ;
    function sub(uint256 tokenId, uint256 key, uint256 value) external ;
    function add(uint256 tokenId, uint256 key, uint256 value) external ;

    function setMany(uint256 tokenId, uint256[8] memory keys, uint256[8] memory values) external ;
    function transferSingle(uint256 tokenIdFrom, uint256 tokenIdTo, uint256 key, uint256 value) external ;
}