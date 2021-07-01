// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./MockBEP20.sol";

contract OtherToken is MockBEP20{
        constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) public MockBEP20(name, symbol,supply) {

    }
}