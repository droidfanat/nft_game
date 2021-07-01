// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../vendor/contracts/BEP20.sol";

contract MockBEP20 is BEP20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) public BEP20(name, symbol) {
        _mint(msg.sender, supply);

    }

    function mint(address to , uint256 amount) public returns (bool) {
        _mint(to, amount);
        return true;
    }
}