// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./UpgradableProxy.sol";


contract HeroStorageProxy is UpgradableProxy{
    constructor(address _implementation) UpgradableProxy(_implementation) public {
    }
} 