// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./IERC20.sol";

interface IERC20WithMaxTotalSupply is IERC20 {
    function maxTotalSupply() external view returns (uint);
}
