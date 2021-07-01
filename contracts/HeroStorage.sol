// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./Constants.sol";
import "./vendor/contracts/ERC721WithBalancesLike1155.sol";
import "./vendor/libraries/access/ManagerIsOwner.sol";
import "./vendor/libraries/proxy/Initializable.sol";
import "./vendor/libraries/access/DungeonsWhitelist.sol"; 




contract HeroStorage is ERC721WithBalancesLike1155, Constants, DungeonsWhitelist, Initializable{

    using SafeMath for uint256;
    using Address for address;
    

    function initialize(address manager_) public payable initializer {
        _setBaseURI('https://example.com/token/');
        _initialize("PactHeroToken", "PACTHT", manager_); 
    }


        mapping (uint256 => address) internal dungeon;


    function enterTheDungeon(uint256 tokenId) public payable onlyDungeonsWhitelist {
           require(dungeon[tokenId] == address(0), "the hero is already in the dungeon");
           dungeon[tokenId] = msg.sender;
    }

    function leaveTheDungeon(uint256 tokenId) public payable {
           require(dungeon[tokenId] == msg.sender, "only the dungeon address is the way to do it");
           dungeon[tokenId] = address(0);
    }


    function issoul(uint256 tokenId) view public returns(bool){
        if (dungeon[tokenId] == address(0)){
            return true;
        }
        return false;
    }


}