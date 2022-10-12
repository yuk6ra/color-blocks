require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: process.env.STAGING_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    }
  },
  gasReporter: {
    enabled: true,
    outputFile: "gas-report.ans",
    currency: "ETH",
    gasPrice: 23,
    noColors: false,
  }
};