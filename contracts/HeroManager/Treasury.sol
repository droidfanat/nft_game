// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../vendor/interfaces/IERC20.sol";
import "../vendor/libraries/math/SafeMath.sol";
import "../vendor/libraries/transfer/SafeERC20.sol";

contract Treasury {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public _PACT;
    function _initialize(IERC20 PACT_) internal {
        _PACT = PACT_;
    }

    // ERC20 address => tokenId => balance
    mapping (address => mapping (uint256 => uint256)) public getTokenBalance;
    function __addTokenBalance(address erc20Address, uint256 tokenId, uint256 amount) private {
        getTokenBalance[erc20Address][tokenId] = getTokenBalance[erc20Address][tokenId].add(amount);
    }
    function __subTokenBalance(address erc20Address, uint256 tokenId, uint256 amount) private {
        getTokenBalance[erc20Address][tokenId] = getTokenBalance[erc20Address][tokenId].sub(amount, "Treasury:_subTokenBalance - not enough balance");
    }
    // PACTs Balance
    uint256 private treasurySelfBalance;
    function getTreasurySelfBalance() public view returns(uint){
        return treasurySelfBalance;
    }
    function __addTreasurySelfBalance(uint256 amount) private {
        treasurySelfBalance = treasurySelfBalance.add(amount);
    }
    function __subTreasurySelfBalance(uint256 amount) private {
        treasurySelfBalance = treasurySelfBalance.sub(amount);
    }
    
    function _takeMoneyFromSender(
        IERC20 currency,
        uint256 tokenId,
        uint256 amountToTokenBalance,
        uint256 amountInPactToTreasury
    ) internal {
        if (address(currency) == address(_PACT)) {
            currency.safeTransferFrom(address(msg.sender), amountInPactToTreasury.add(amountToTokenBalance)); //* (10** uint256(_PACT.decimals())));
        } else {
            currency.safeTransferFrom(address(msg.sender), amountToTokenBalance); //* (10** uint256(currency.decimals())));
            _PACT.safeTransferFrom(address(msg.sender), amountInPactToTreasury); //* (10** uint256(_PACT.decimals())));
        }

        __addTokenBalance(address(currency), tokenId, amountToTokenBalance);
        __addTreasurySelfBalance(amountInPactToTreasury);
    }

    function _takeMoneyFromSenderOnlyToTreasury(
        uint256 amountInPactToTreasury
    ) internal {
        _PACT.safeTransferFrom(address(msg.sender), amountInPactToTreasury);

        __addTreasurySelfBalance(amountInPactToTreasury);
    }

    function _sendAllMoneyByToken(
        IERC20 currency,
        uint256 tokenId
    ) internal {
        uint256 amount = getTokenBalance[address(currency)][tokenId];
        __subTokenBalance(address(currency), tokenId, amount);
        currency.safeTransfer(address(msg.sender), amount );
    }

    function _sendPACTsFromTreasury(uint256 amount, address account) internal {
        __subTreasurySelfBalance(amount);
        _PACT.safeTransfer(account, amount );
    }

    function _burnPACTsFromTreasury(uint256 amount) internal {
        __subTreasurySelfBalance(amount);
        _PACT.safeBurn(amount);
    }

}


