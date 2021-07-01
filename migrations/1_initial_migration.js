const Migrations = artifacts.require("Migrations");


module.exports = function(deployer, network, accounts) {
  if (deployer.network === 'test' && deployer.network === 'development') {
    return;
  }
  deployer.deploy(Migrations);
};


//0x2c9e5ef4F9EcCACC225d6b7866ccAeDFA57389bE FarmingPull
//0x5D63441469784964Ed04F086104a60bD8656f3BF FarmingPullProxy
//0x017c591243ceb564B1Ff73436Fbb2BF77b8b5b9a MasterChef
//0xAf2C67928d1b6437c58B7f803E0217235a89584A MasterChefProxy