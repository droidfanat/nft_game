// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract EconomicVariables {
    mapping (uint256 => bool) private variablesKeys;
    mapping (uint256 => uint256) private variablesValues;

    function _createOrUpdateVariable(uint256 key, uint256 value) internal {
        variablesKeys[key] = true;
        variablesValues[key] = value;
    }
    function _removeVariableKey(uint256 key) internal {
        variablesKeys[key] = false;
        variablesValues[key] = 0;
    }

    function getVariable(uint256 key) public existedVariableKeys(key) view returns (uint256) {
        return variablesValues[key];
    }

    function _updateVariable(uint256 key, uint256 value) internal existedVariableKeys(key) {
        variablesValues[key] = value;
    }

    modifier existedVariableKeys(uint256 key) {
        //require(variablesKeys[key], "EconomicVariables: key is not exists");
        _;
    }
}