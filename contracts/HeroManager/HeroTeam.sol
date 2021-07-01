// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "../vendor/interfaces/IERC20.sol";

abstract contract HeroTeam {


    struct HeroTeamPool {
        IERC20 token;         
        bool _isHeroTeams;      
    }

    HeroTeamPool[] public allowedHeroTeams;


    //address[] public existingHeroTeams;
    uint256 public lastHeroTeamId;

    function _enableHeroTeam(IERC20 currency) internal returns (uint256) {
        allowedHeroTeams.push(HeroTeamPool({
            token: currency,
            _isHeroTeams: true
        }));
    }

    function _getHeroTeamAddress (uint id) internal view returns(address){
        return address(allowedHeroTeams[id].token);
    }

    function _disableHeroTeam(uint id) internal {
        allowedHeroTeams[id]._isHeroTeams = false;
    }

    // function getEnabledHeroTeams() public view returns (address[] memory) {
    //     address[] memory enabledHeroTeams;

    //     for (uint256 i = 0; i < existingHeroTeams.length; ++i) {
    //         address currentCurrency = existingHeroTeams[i];
    //         if (allowedHeroTeams[currentCurrency] != 0) {
    //              //enabledHeroTeams.push(currentCurrency);
    //         }
    //     }

    //     return enabledHeroTeams;
    // }

    function poolLength() external view returns (uint256) {
        return allowedHeroTeams.length;
    }

    modifier allowedHeroTeam(uint id) {
        require(allowedHeroTeams[id]._isHeroTeams != false, 'HeroTeamsRegistry :: Address is already');
        _;
    }
}
