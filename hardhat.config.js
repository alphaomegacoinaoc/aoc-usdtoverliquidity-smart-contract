require("@nomicfoundation/hardhat-verify");
require("@openzeppelin/hardhat-upgrades");
require('dotenv').config();

const{BSC_RPC_URL_,PRIVATE_KEY,ETHERSCAN_API_KEY,AMOY_RPC_URL} = process.env;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  settings: {
    optimizer: {
      viaIR: true,
      enabled: true,
      runs: 200, 
    },
  },
  debug: {
    revertStrings: "strip", // Disables revert strings
  },
  networks:{
    // bscTestnet: {
    //   url: BSC_RPC_URL_,
    //   accounts: [`0x${PRIVATE_KEY}`]
    // }
    amoy: {
      url: AMOY_RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  },
  sourcify:{
    enabled: true,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,  //V2 key
  },

};
