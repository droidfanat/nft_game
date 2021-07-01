
const {
    address,
    encodeParameters
} = require('../test/utils/Ethereum');

const HeroStorage = artifacts.require('HeroStorage');
const HeroManager = artifacts.require('HeroManager');
const HeroStorageProxy = artifacts.require('HeroStorageProxy');
const HeroManagerProxy = artifacts.require('HeroManagerProxy');


module.exports = function (deployer, network, accounts) {
    
    if (deployer.network === 'test') {
        return;
    }

    deployer.then(async () => {

        console.log(deployer.network);

    
        if (deployer.network === 'bsc') {
            pact_address = "0x66e7CE35578A37209d01F99F3d2fF271f981F581";
        }
        
        if (deployer.network === 'bsctest') {
            pact_address = "0xe7AF71eb810C5929BdbbcE97966EBc8Ea0DE38E1";
        }

        if (deployer.network === 'development') {
            pact_address = address(0);
        }
      
        this.heroStorage = await HeroStorage.at(HeroStorageProxy.address);
        this.heroManager = await HeroManager.at(HeroManagerProxy.address);

        await this.heroManager.initialize(pact_address, HeroStorageProxy.address, accounts[0], {from:accounts[0]});
        await this.heroStorage.initialize(HeroManagerProxy.address, {from:accounts[0]});
    });
};