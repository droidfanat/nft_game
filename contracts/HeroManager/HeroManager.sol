// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../vendor/interfaces/IERC20.sol";
import "../vendor/interfaces/IStorage.sol";
import "../vendor/libraries/access/Ownable.sol";
import "../vendor/libraries/proxy/Initializable.sol";
import "./EconomicVariables.sol";
import "./HeroTeam.sol";
import "./Treasury.sol"; 
import "../Constants.sol";
//import "@nomiclabs/buidler/console.sol";

contract HeroManager is Ownable, EconomicVariables, HeroTeam, Treasury, Constants, Initializable {
    using SafeMath for uint256;

    IStorage public _HeroStorage;
    address public _incentivesPool;
 
    function initialize(  
        IERC20 PACT_,
        IStorage HeroStorage_,
        address incentivesPool_
    ) public initializer {
        Treasury._initialize(PACT_);
        Ownable._initialize();
        _HeroStorage = HeroStorage_;
        _incentivesPool = incentivesPool_;
        _setVariablesDefaultValues();
        _editHeroTeamSettings(_enableHeroTeam(PACT_), 10e18, 100e18);
    }


    modifier onlyHeroOwner(uint256 heroId) {
        require(_HeroStorage.ownerOf(heroId) == msg.sender, "HeroManager::onlyHeroOwner: only hero owner allowed");
        _;
    }

/////////////////////////////// BaseEconomicVariables
    uint256 public constant CREATION_COST = 10;
    uint256 public constant LEVEL_UP_COST = 11;
    uint256 public constant BURN_PART_IN_PPM_FOR_CREATION = 101;
    uint256 public constant BURN_PART_IN_PPM_FOR_MULTICAST_FEE = 102;
    uint256 public constant BURN_PART_IN_PPM_FOR_LEVEL_UP = 103;

    function _setVariablesDefaultValues() internal {
        _createOrUpdateVariable(CREATION_COST, 100e18);
        _createOrUpdateVariable(LEVEL_UP_COST, 100e18);
        _createOrUpdateVariable(BURN_PART_IN_PPM_FOR_CREATION, 20000);
        _createOrUpdateVariable(BURN_PART_IN_PPM_FOR_MULTICAST_FEE, 20000);
        _createOrUpdateVariable(BURN_PART_IN_PPM_FOR_LEVEL_UP, 20000);
    }

    function updateVariable(uint256 key, uint256 value) public onlyOwner {
        _updateVariable(key, value);
    }

/////////////////////////////// HeroTeam
    uint256 public constant HERO_TEAM_VARIABLE_MODIFIER_MIN_AMOUNT_IN_TOKEN = 1002;
    uint256 public constant HERO_TEAM_VARIABLE_MODIFIER_MAX_AMOUNT_IN_TOKEN = 1003;

    function disableHeroTeam(uint256 currencyId) public allowedHeroTeam(currencyId) onlyOwner {
        _disableHeroTeam(currencyId); 
    }
    function enableHeroTeam(
        IERC20 currency,
        uint256 minAmountInToken,
        uint256 maxAmountInToken
    ) public onlyOwner {
        _editHeroTeamSettings(
            _enableHeroTeam(currency),
            minAmountInToken,
            maxAmountInToken
        );
    }

    function editHeroTeamSettings(
        uint256 currencyId, 
        uint256 minAmountInToken,
        uint256 maxAmountInToken
    ) public allowedHeroTeam(currencyId) onlyOwner {
        _editHeroTeamSettings(
            currencyId,
            minAmountInToken,
            maxAmountInToken
        );
    }

    function _editHeroTeamSettings(
        uint256 heroTeamVariableKey,
        uint256 minAmountInToken,
        uint256 maxAmountInToken
    ) internal {
        _createOrUpdateVariable(
            heroTeamVariableKey.add(HERO_TEAM_VARIABLE_MODIFIER_MIN_AMOUNT_IN_TOKEN),
            minAmountInToken
        );
        _createOrUpdateVariable(
            heroTeamVariableKey.add(HERO_TEAM_VARIABLE_MODIFIER_MAX_AMOUNT_IN_TOKEN),
            maxAmountInToken
        );
    }

    function getHeroTeamSettingsValue(
        uint256 currencyId, 
        uint256 key
    ) public allowedHeroTeam(currencyId) view returns (uint256) {
        return getVariable(currencyId.add(key));
    }

/////////////////////////////// CreateHero
 

    function createHero(uint256 currencyId, uint256 amountToHero) public allowedHeroTeam(currencyId) returns (uint256) {
        require(
            amountToHero >= getHeroTeamSettingsValue(currencyId, HERO_TEAM_VARIABLE_MODIFIER_MIN_AMOUNT_IN_TOKEN),
            "HeroManager::createHero: amountToHero not enough"
        );
        require(
            amountToHero <= getHeroTeamSettingsValue(currencyId, HERO_TEAM_VARIABLE_MODIFIER_MAX_AMOUNT_IN_TOKEN),
            "HeroManager::createHero: amountToHero so big"
        );

        uint256 heroId = _createHero(
            currencyId, 
            1, 
            1, 
            1, 
            1,
            30 days
            ); 

        uint256 amountToTreasury = getVariable(CREATION_COST);
        _takeMoneyFromSender(IERC20(_getHeroTeamAddress(currencyId)), heroId, amountToHero, amountToTreasury);

        uint256 amountToBurn = amountToTreasury.mul(getVariable(BURN_PART_IN_PPM_FOR_CREATION)) / 1000000;
        
        _burnPACTsFromTreasury(amountToBurn);

        return heroId;
    }

    function createHeroWithMulticast(uint256 currencyId, uint256 amountToHero) public allowedHeroTeam(currencyId) returns (uint256) {
        (
            uint256 warriorAmount,
            uint256 farmerAmount,
            uint256 traderAmount,
            uint256 predictorAmount,
            uint256 multicastFeeInPact
        ) = _calculateMulticast(amountToHero);

        uint256 heroId = _createHero(
            currencyId,
            warriorAmount.add(1),
            farmerAmount.add(1),
            traderAmount.add(1),
            predictorAmount.add(1),
            30 days
        );

        uint256 creationCost = getVariable(CREATION_COST);
        uint256 amountToTreasury = creationCost.add(multicastFeeInPact);

        _takeMoneyFromSender(IERC20(_getHeroTeamAddress(currencyId)), heroId, amountToHero, amountToTreasury);

        creationCost = creationCost.mul(getVariable(BURN_PART_IN_PPM_FOR_CREATION)).div(1000000);
        multicastFeeInPact = multicastFeeInPact.mul(getVariable(BURN_PART_IN_PPM_FOR_MULTICAST_FEE)).div(1000000);
        uint256 amountToBurn = creationCost.add(multicastFeeInPact);
        _burnPACTsFromTreasury(amountToBurn);

        return heroId;
    }

    function _createHero(
        uint256 currencyId,
        uint256 warriorAmount,
        uint256 farmerAmount,
        uint256 traderAmount,
        uint256 predictorAmount,
        uint256 lockTime
    ) internal returns (uint256) {
                 
        

        uint256 heroId = _HeroStorage.mint(
            msg.sender,
            [
                BLOCK_CREATED_AT,
                BLOCK_BALANCE_UPDATED_AT,
                TIME_ALLOW_BURN,

                HERO_TYPE,
                SKILL_WARRIOR,
                SKILL_FARMER,
                SKILL_TRADER,
                SKILL_PREDICTOR
            ],
            [
                block.number,
                block.number,
                block.timestamp.add(lockTime),

                currencyId,
                warriorAmount,
                farmerAmount,
                traderAmount,
                predictorAmount
            ]
        );

        return heroId;
    }

/////////////////////////////// MulticastingSettings

    function _calculateMulticast(
        uint256 multicastAmount
    ) internal view returns (
        uint256 warriorAmount,
        uint256 farmerAmount,
        uint256 traderAmount,
        uint256 predictorAmount,
        uint256 feeInPact
    ) {
        uint256 min;
        uint256 max;
        uint256 maxValueChance;
        (min, max, maxValueChance, feeInPact) = getMinMaxForMulticast(multicastAmount);

        uint256 totalAmount;
        uint256 seed = __computerSeed();
        if (seed % 100 <= maxValueChance) {
            totalAmount = max;
        } else {
            totalAmount = min.add(seed.mod(max.sub(min)));
        }

        warriorAmount = totalAmount.div(4);
        farmerAmount = totalAmount.div(4);
        traderAmount = totalAmount.div(4);
        predictorAmount = totalAmount.div(4) + totalAmount % 4;
    }

    function getMinMaxForMulticast(
        uint256 multicastAmount
    ) public pure returns (
        uint256 min,
        uint256 max,
        uint256 maxValueChance,
        uint256 feeInPact
    ) {
        if (multicastAmount <= 100e18) {
            min = 0;
            max = 1;
            maxValueChance = 50;
            feeInPact = 100e18;
            return(min , max, maxValueChance, feeInPact);
        }
        if (multicastAmount <= 200e18) {
            min = 1;
            max = 2;
            maxValueChance = 25;
            feeInPact = 100e18;
            return(min , max, maxValueChance, feeInPact);
        }
        if (multicastAmount <= 1000e18) {
            min = 2;
            max = 10;
            maxValueChance = 10;
            feeInPact = 100e18;
            return(min , max, maxValueChance, feeInPact);
        }
        if (multicastAmount <= 2000e18) {
            min = 10;
            max = 20;
            maxValueChance = 5;
            feeInPact = 100e18;
            return(min , max, maxValueChance, feeInPact);
        }
        if (multicastAmount <= 10000e18) {
            min = 20;
            max = 100;
            maxValueChance = 2;
            feeInPact = 100e18;
            return(min , max, maxValueChance, feeInPact);
        }

        min = 100;
        max = 200;
        maxValueChance = 2;
        feeInPact = 4000e18;
    }

    function __computerSeed() private view returns (uint256) {
        // from fomo3D
        uint256 seed = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number)
            )));
        return seed;
    }

/////////////////////////////// LevelUp

    function levelUp(
        uint256 heroId,
        uint256 warriorAmount,
        uint256 farmerAmount,
        uint256 traderAmount,
        uint256 predictorAmount,
        uint256 bonusDirectionKey
    ) public onlyHeroOwner(heroId) {
        uint256 totalAmount = warriorAmount.add(farmerAmount).add(traderAmount).add(predictorAmount);
        _takeMoneyFromSenderOnlyToTreasury(totalAmount.mul(getVariable(LEVEL_UP_COST)));

        uint256 bonusAmount = calculateBonusForLevelUp(totalAmount);
        if (bonusAmount > 0) {
            if (bonusDirectionKey == SKILL_WARRIOR) {
                warriorAmount = warriorAmount.add(bonusAmount);
            }
            else if (bonusDirectionKey == SKILL_FARMER) {
                farmerAmount = farmerAmount.add(bonusAmount);
            }
            else if (bonusDirectionKey == SKILL_TRADER) {
                traderAmount = traderAmount.add(bonusAmount);
            }
            else if (bonusDirectionKey == SKILL_PREDICTOR) {
                predictorAmount = predictorAmount.add(bonusAmount);
            } else {
                warriorAmount = warriorAmount.add(bonusAmount.div(4));
                farmerAmount = farmerAmount.add(bonusAmount.div(4));
                traderAmount = traderAmount.add(bonusAmount.div(4));
                predictorAmount = predictorAmount.add(bonusAmount.div(4)).add(bonusAmount % 4);
            }
        }

        _HeroStorage.add(heroId, SKILL_WARRIOR, warriorAmount);
        _HeroStorage.add(heroId, SKILL_FARMER, farmerAmount);
        _HeroStorage.add(heroId, SKILL_TRADER, traderAmount);
        _HeroStorage.add(heroId, SKILL_PREDICTOR, predictorAmount);
    }

    function calculateBonusForLevelUp(
        uint256 totalAmount
    ) public pure returns (uint256) {
        if (totalAmount <= 10e18) {
            return 0;
        }
        if (totalAmount <= 50e18) {
            return 5;
        }
        if (totalAmount <= 100e18) {
            return 10;
        }
        if (totalAmount <= 500e18) {
            return 20;
        }
        if (totalAmount <= 2000e18) {
            return 50;
        }
        return 100;
    }

/////////////////////////////// RetireHero
    function retireHero(uint256 heroId) public onlyHeroOwner(heroId) {
        require(_HeroStorage.get(heroId, TIME_ALLOW_BURN) < block.timestamp, "HeroManager::retireHero: TIME_ALLOW_BURN - not allowed yet");
        _sendAllMoneyByToken(IERC20(_getHeroTeamAddress(_HeroStorage.get(heroId, HERO_TYPE))), heroId);
        _HeroStorage.burn(heroId);
    }

/////////////////////////////// IncentivesPool

    function sendAllPACTsFromTreasuryToIncentivesPool() public {
        require(_incentivesPool != address(0), '');
        _sendPACTsFromTreasury(getTreasurySelfBalance(), _incentivesPool);
    }

}