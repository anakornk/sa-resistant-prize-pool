var SimpleSumGame = artifacts.require("./SimpleSumGame.sol");

module.exports = function(deployer) {
  let sum = 5;
  deployer.deploy(SimpleSumGame, sum);
};
