const hre = require("hardhat");

const {ethers, upgrades} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const Token = await ethers.getContractFactory("Test");
    const token = await Token.deploy("0xB1B68DFC4eE0A3123B897107aFbF43CEFEE9b0A2","0xBb19939D96ca5cd34ec2919eE9Da3a1b70D7A77C",{gasPrice: 200000000000});
    console.log("BavaTestContract address:", token.address); //0x79D903745Fc78C4644aa481d4ECd4665e04De413

    //await hre.run("verify:verify", {address: token.address});
  
    console.log("Deployed contract address:", token.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });