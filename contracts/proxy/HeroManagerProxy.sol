// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./UpgradableProxy.sol";


contract HeroManagerProxy is UpgradableProxy{
    constructor(address _implementation) UpgradableProxy(_implementation) public {
    }
} 