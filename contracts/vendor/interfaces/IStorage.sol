// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./IBalancesLikeERC1155.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";

interface IStorage is IBalancesLikeERC1155, IERC721, IERC721Metadata, IERC721Enumerable{
}
