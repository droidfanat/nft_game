// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "../libraries/math/SafeMath.sol";
import "../libraries/access/ManagerIsOwner.sol";
import "../interfaces/IBalancesLikeERC1155.sol";
import "../contracts/ERC721.sol";


contract ERC721WithBalancesLike1155 is ManagerIsOwner, IBalancesLikeERC1155, ERC721
{
    using SafeMath for uint256;

    // tokenId => (key => value)
    mapping (uint256 => mapping(uint256 => uint256)) internal balances;

    uint256 public tokensCount;

    modifier tokenIdExists(uint256 tokenId) {
        require(tokenId < tokensCount, "tokenIdExists: tokenId is not exists");
        _;
    }

    function _initialize (string memory name, string memory symbol, address manager_) internal{
        _initialize_erc721(name, symbol);
        _initialize_manager(manager_);
    }

    function transfer(address to, uint256 tokenId) public {
        _transfer(msg.sender, to, tokenId);
    }
 
    function burn(uint256 tokenId)
        public  override
        onlyManager tokenIdExists(tokenId)
    {
        _burn(tokenId);
    }

    function mint(address to, uint256[8] memory keys, uint256[8] memory amounts)
        public override
        onlyManager
        returns (uint256)
    {
        uint256 tokenId = tokensCount;
        ++tokensCount;
        _mint(to, tokenId);
        setMany(tokenId, keys, amounts);
        return tokenId;
    }

    function get(uint256 tokenId, uint256 key)
        public view override
        tokenIdExists(tokenId)
        returns(uint256)
    {
        return balances[tokenId][key];
    }

    function getListBalancesForSingleId(uint256 tokenId, uint256[] memory keys)
        public view override
        returns (uint256[] memory)
    {
        uint256[] memory listForSingle = new uint256[](keys.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            listForSingle[i] = balances[tokenId][keys[i]];
        }

        return listForSingle;
    }


    function set(uint256 tokenId, uint256 key, uint256 value)
        public override
        onlyManager tokenIdExists(tokenId)
    {
        balances[tokenId][key] = value;
    }

    function sub(uint256 tokenId, uint256 key, uint256 value)
        public override
        onlyManager tokenIdExists(tokenId)
    {
        _sub(tokenId, key, value);
    }

    function _sub(uint256 tokenId, uint256 key, uint256 value) internal {
        balances[tokenId][key] = balances[tokenId][key].sub(value, "Balances::sub - not enough balance");
    }

    function add(uint256 tokenId, uint256 key, uint256 value)
        public override
        onlyManager tokenIdExists(tokenId)
    {
        _add(tokenId, key, value);
    }

    function _add(uint256 tokenId, uint256 key, uint256 value) internal {
        balances[tokenId][key] = balances[tokenId][key].add(value); 
    }

    function setMany(uint256 tokenId, uint256[8] memory keys, uint256[8] memory values)
        public override
        onlyManager tokenIdExists(tokenId)
    {
        require(keys.length == values.length, "keys and values length mismatch");

        for (uint256 i = 0; i < keys.length; ++i) {
            balances[tokenId][keys[i]] = values[i];
        }
    }

    function transferSingle(uint256 tokenIdFrom, uint256 tokenIdTo, uint256 key, uint256 value)
        public override
        onlyManager tokenIdExists(tokenIdFrom) tokenIdExists(tokenIdTo)
    {
        _sub(tokenIdFrom, key, value);
        _add(tokenIdTo, key, value);

        emit TransferSingle(tokenIdFrom, tokenIdTo, key, value);

    }
}