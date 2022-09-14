const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const Token = await ethers.getContractFactory("Token", {
        libraries: {
            IterableMapping: "0x4aD4E3154EBaFC8df3b03B55359baA4d218B6eA5"
        }
    });

    const token = await Token.deploy();
  
    console.log("Token address:", token.address);
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });