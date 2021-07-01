//const { expectRevert, time } = require('@openzeppelin/test-helpers');
const HeroStorage = artifacts.require('HeroStorage');
const assertRevert = require("./assertRevert");
const {
    expectEqual,
    expectRevert,
    expectEvent,
    BN,
} = require('./utils/JS');

const BLOCK_CREATED_AT = 0;
const BLOCK_BALANCE_UPDATED_AT = 1;
const TIME_ALLOW_BURN = 3;
const HERO_TYPE = 1000;
const SKILL_WARRIOR = 1100;
const SKILL_FARMER = 1101;
const SKILL_TRADER = 1102;
const SKILL_PREDICTOR = 1103;



contract('HeroStorage', ([alice, bob, carol, dungeon0, dungeon1, minter]) => {
    beforeEach(async () => {
        this.heroStorage = await HeroStorage.new();
        await this.heroStorage.initialize(minter);
    });


    async function mint(heroStorage, owner) {
        await heroStorage.mint(owner, [
            BLOCK_CREATED_AT,
            BLOCK_BALANCE_UPDATED_AT,
            TIME_ALLOW_BURN,
            HERO_TYPE,
            SKILL_WARRIOR,
            SKILL_FARMER,
            SKILL_TRADER,
            SKILL_PREDICTOR
        ], [
            "100",
            "100",
            "30000",
            "1",
            "10",
            "10",
            "10",
            "10"
        ], { from: minter });
    }




    it('mint hero/mint skills', async () => {
        await mint(this.heroStorage, alice);
        await mint(this.heroStorage, bob);

        for (let index = 0; index < 12; index++) {
            await mint(this.heroStorage, carol);
        }

    }


    );

    it('get balanceOf', async () => {
        await mint(this.heroStorage, alice);
        await mint(this.heroStorage, bob);

        for (let index = 0; index < 12; index++) {
            await mint(this.heroStorage, carol);
        }
        console.log((await this.heroStorage.tokensCount()).toString());
        console.log((await this.heroStorage.balanceOf(alice, { from: alice })).toString());
        console.log((await this.heroStorage.balanceOf(bob, { from: bob })).toString());
        console.log((await this.heroStorage.balanceOf(carol, { from: carol })).toString());
    });


    it('get balanceof  scills', async () => {
        for (let index = 0; index < 12; index++) {
            await mint(this.heroStorage, carol);
        }

        //console.log((await this.heroStorage.balanceOf(carol, {from: carol}))


        //console.log("test",(await this.heroStorage.tokenOfOwnerByIndex(carol,index)).toString());

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

        store_data = [
            "100",
            "100",
            "30000",
            "1",
            "10",
            "10",
            "10",
            "10"
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
            await this.heroStorage.tokenOfOwnerByIndex(carol, 1), storage_indexes));

        for (let index = 0; index < resault.length; index++) {
            console.log(storage_indexes_name[index], resault[index].toString());
            expectEqual(store_data[index], resault[index].toString());
        }


    });


    it('transfer', async () => {
        await mint(this.heroStorage, alice);


        console.log("balance alice", (await this.heroStorage.balanceOf(alice, { from: alice })).toString());
        console.log("balance bob", (await this.heroStorage.balanceOf(bob, { from: bob })).toString());

        await this.heroStorage.transfer(bob, 0, { from: alice });


        console.log("balance alice", (await this.heroStorage.balanceOf(alice, { from: alice })).toString());
        console.log("balance bob", (await this.heroStorage.balanceOf(bob, { from: bob })).toString());

        
        await assertRevert(this.heroStorage.transfer(bob, 0, { from: alice }));
        await mint(this.heroStorage, alice);
        await assertRevert(this.heroStorage.transfer(bob, 1, { from: bob }));
    });


    it('Dungeons', async () => {
        await mint(this.heroStorage, bob);
        await mint(this.heroStorage, alice);
        await this.heroStorage.whitelistAdd(dungeon0, { from: minter });
        await this.heroStorage.whitelistAdd(dungeon1, { from: minter });

        await this.heroStorage.enterTheDungeon(0, { from: dungeon0 });
        await this.heroStorage.enterTheDungeon(1, { from: dungeon1 });
        await assertRevert(this.heroStorage.enterTheDungeon(0, { from: dungeon1 }));

        await this.heroStorage.leaveTheDungeon(0, { from: dungeon0 });
        await assertRevert(this.heroStorage.leaveTheDungeon(1, { from: minter }));


    });

});