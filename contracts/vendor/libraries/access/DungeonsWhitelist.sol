// "SPDX-License-Identifier: MIT"
pragma solidity 0.6.12;


import "./ManagerIsOwner.sol";

abstract contract DungeonsWhitelist is ManagerIsOwner {
    mapping(address => bool) whitelist;
    event AddedDungeonToWhitelist(address indexed account);
    event RemovedDungeonFromWhitelist(address indexed account);

    modifier onlyDungeonsWhitelist() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function whitelistAdd(address _address) public onlyManager {
        whitelist[_address] = true;
        emit AddedDungeonToWhitelist(_address);
    }

    function whitelistRemove(address _address) public onlyManager {
        whitelist[_address] = false;
        emit RemovedDungeonFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}