// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./MockBEP20.sol";

contract Pact is MockBEP20{
        constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) public MockBEP20(name, symbol,supply) {

    }

    function burn(uint256 amount) public payable {
        _burn(msg.sender, amount);
    }

}