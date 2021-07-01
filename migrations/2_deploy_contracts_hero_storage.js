
var HeroStorage = artifacts.require("HeroStorage");


module.exports = function (deployer, network, accounts) {

    if (deployer.network === 'test' && deployer.network === 'development') {
        return;
      }
      
    deployer.then(async () => {
        //######################################  FARM  ###################################################################
        console.log('Deploy: ', "HeroStorage");
        await deployer.deploy(HeroStorage).then(async () => {
        });


    });
};