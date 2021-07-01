
var Proxy = artifacts.require("HeroStorageProxy");
var HeroStorage = artifacts.require("HeroStorage");


module.exports = function (deployer, network, accounts) {
    if (deployer.network === 'test' && deployer.network === 'development') {
        return;
    }

    deployer.then(async () => {
        //######################################  FARM  ###################################################################
        console.log('Deploy: ', "PACT POOL PROXY");
        await deployer.deploy(Proxy,HeroStorage.address).then(async () => {
        });
    });
};