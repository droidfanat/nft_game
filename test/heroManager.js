const { time } = require('@openzeppelin/test-helpers');
const HeroStorage = artifacts.require('HeroStorage');
const HeroManager = artifacts.require('HeroManager');
const HeroStorageProxy = artifacts.require('HeroStorageProxy');
const HeroManagerProxy = artifacts.require('HeroManagerProxy');
const Pact = artifacts.require('Pact');
const OtherToken = artifacts.require('OtherToken');
const assertRevert = require("./assertRevert");
const {
    expectEqual,
    expectRevert,
    expectEvent,
    BN,
} = require('./utils/JS');
const {
    address,
    minerStart,
    minerStop,
    encodeParameters,
    mineBlock,
    mineBlockNumber,
    getBlockNumber
  } = require('./utils/Ethereum');



const BLOCK_CREATED_AT = 0;
const BLOCK_BALANCE_UPDATED_AT = 1;
const TIME_ALLOW_BURN = 3;
const HERO_TYPE = 1000;
const SKILL_WARRIOR = 1100;
const SKILL_FARMER = 1101;
const SKILL_TRADER = 1102;
const SKILL_PREDICTOR = 1103;



contract('HeroManager', ([alice, bob, innPool, carol, dungeon0, dungeon1, minter]) => {
    beforeEach(async () => {
        this.heroStorage = await HeroStorage.new();
        this.heroStorageProxy = await HeroStorageProxy.new(this.heroStorage.address);
        this.heroStorage = await HeroStorage.at(this.heroStorageProxy.address);

        this.pact = await Pact.new("Pact","Pact","9000000000000000000000",{from:alice});
        this.otherToken = await Pact.new("otherToken","OTH","1000000000000000000000",{from:bob});
        this.heroManager = await HeroManager.new({from:minter});
        this.heroManagerProxy = await HeroManagerProxy.new(this.heroManager.address ,{from:minter});
        this.heroManager = await HeroManager.at(this.heroManagerProxy.address);


        await this.heroManager.initialize(this.pact.address, this.heroStorage.address, innPool, {from:minter});
        await this.heroStorage.initialize(this.heroManager.address);
        
        //await this.heroManager.enableHeroTeam(this.pact.address, "10000000000000000000", "100000000000000000000", {from:minter});
    });

    it('create hero', async () => {
        await this.pact.approve(this.heroManager.address, '110000000000000000000', { from: alice });
        await this.heroManager.createHero("0", "10000000000000000000", {from:alice});
        
        console.log((await this.pact.balanceOf(this.heroManager.address)).toString());
        //console.log("debug,fee ",(await this.heroManager.debug()).toString());
    });

    it('create multicast hero', async () => {
        await this.pact.approve(this.heroManager.address, '2210000000000000000000', { from: alice });
        await this.heroManager.createHeroWithMulticast(0, "2000000000000000000000", {from:alice});
        
        console.log((await this.pact.balanceOf(this.heroManager.address)).toString());
        //console.log("debug_multicast,fee ",(await this.heroManager.debug()).toString());
        storage_indexes = [
            BLOCK_CREATED_AT,
            BLOCK_BALANCE_UPDATED_AT,
            TIME_ALLOW_BURN,
            HERO_TYPE,
            SKILL_WARRIOR,
            SKILL_FARMER,
            SKILL_TRADER,
            SKILL_PREDICTOR
        ];

        storage_indexes_name = [
            "BLOCK_CREATED_AT",
            "BLOCK_BALANCE_UPDATED_AT",
            "TIME_ALLOW_BURN",
            "HERO_TYPE",
            "SKILL_WARRIOR",
            "SKILL_FARMER",
            "SKILL_TRADER",
            "SKILL_PREDICTOR"
        ];

        resault = (await this.heroStorage.getListBalancesForSingleId(
            await this.heroStorage.tokenOfOwnerByIndex(alice, 0), storage_indexes));

        for (let index = 0; index < resault.length; index++) {
            console.log(storage_indexes_name[index], resault[index].toString());
        }
    });

  

    // it('retireHero hero', async () => {
    //     await this.pact.approve(this.heroManager.address, '210000000000000000000', { from: alice });
    //     await this.heroManager.createHeroWithMulticast(0, "10000000000000000000", {from:alice});
        
    //     console.log((await this.pact.balanceOf(this.heroManager.address)).toString());
    //     await time.advanceBlockTo('400');

    //     await this.heroManager.retireHero(0, {from:alice});
    //     console.log((await this.pact.balanceOf(this.heroManager.address)).toString())
    // });



});



