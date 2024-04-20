const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const USDTOverLiquidityContribution = artifacts.require("USDTOverLiquidityContribution");

module.exports = async function (deployer) {

  // await deployProxy(VestingVault, ["0x8BE3f52CA83E7C2aEf7C33dcE7fAB0106CDfa829"], { deployer, kind: "uups" });
  // const vesting = await VestingVault.deployed();

  await deployProxy(USDTOverLiquidityContribution, ["0x299FEA00d96C7f9dCf6C0BD93DDa52D877970175"], { deployer, kind: "uups" });
  // const vesting = await CrowdsaleV2.deployed();
  
  // const duration = {
  //   seconds: function (val) { return val; },
  //   minutes: function (val) { return val * this.seconds(60); },
  //   hours: function (val) { return val * this.minutes(60); },
  //   days: function (val) { return val * this.hours(24); },
  //   weeks: function (val) { return val * this.days(7); },
  //   years: function (val) { return val * this.days(365); },
  // };

  // // Dev comments - For development closing time is set to 30 days
  // const latestTime = Math.floor(new Date().getTime() / 1000);
  // const _openingTime = latestTime + duration.minutes(1);
  // const _closingTime = _openingTime + duration.days(30);
  // const _arcTokenPurchaseClosingTime = _openingTime + duration.hours(72);
 
  // // Dev comments - accounts[0] takes first account from metamask
  // await deployProxy(CrowdSale, [1000, "0x5705d286e8fc970ca5dFa5C480b708126b6FcB03", "0x8BE3f52CA83E7C2aEf7C33dcE7fAB0106CDfa829", vesting.address, _openingTime, _closingTime, vesting.address, "0x0000000000000000000000000000000000000000000000000000000000000000"], { deployer, kind: "uups" });
  // await CrowdSale.deployed();


    // await upgradeProxy("0x68C3e3f9b4c9cb5FdFc53eBD4071ED18f67413b4", VestingVault, { deployer, kind: "uups" });
};

