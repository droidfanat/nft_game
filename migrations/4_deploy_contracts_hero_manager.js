
var HeroManager = artifacts.require("HeroManager");


module.exports = function (deployer, network, accounts) {

    if (deployer.network === 'test' && deployer.network === 'development') {
        return;
      }
      
    deployer.then(async () => {
        //######################################  FARM  ###################################################################
        console.log('Deploy: ', "HeroManager");
        await deployer.deploy(HeroManager).then(async () => {
        });


    });
};