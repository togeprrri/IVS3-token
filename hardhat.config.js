require("@nomicfoundation/hardhat-toolbox");

const ALCHEMY_API_KEY = "eo788akRJSIdQe_SEURhwLlgnWl3WQhR";


const GOERLI_PRIVATE_KEY = "5c902b7bb0fd5e5f141de5dc0b11fae96a0279d106a0d89bef4f226c2ab2343b";


module.exports = {
  solidity: "0.8.13",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  }
};
