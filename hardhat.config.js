require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

// const [API_URL, ETHERSCAN_KEY, PRIVATE_KEY] =  process.env
module.exports = {
  solidity:{
    version: "0.8.24",
    settings:{
      optimizer : {
        enabled: true,
        runs:200
      }
    }
  },
  networks: {
    baseSepolia: {
      url: process.env.API_URL,
      //@ts-ignore
      accounts:[process.env.PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: {
      baseSepolia: process.env.ETHERSCAN_KEY
    }
  }

};