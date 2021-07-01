
var Proxy = artifacts.require("HeroManagerProxy");
var HeroManager = artifacts.require("HeroManager");


module.exports = function (deployer, network, accounts) {
    if (deployer.network === 'test' && deployer.network === 'development') {
        return;
    }

    deployer.then(async () => {
        //######################################  FARM  ###################################################################
        console.log('Deploy: ', "HeroManagerProxy");
        await deployer.deploy(Proxy,HeroManager.address).then(async () => {
        });
    });
};