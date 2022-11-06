const hre = require("hardhat");

const {ethers, upgrades} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const Token = await ethers.getContractFactory("VirtualEquityToken");
    const token = await Token.deploy({gasPrice: 200000000000});
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