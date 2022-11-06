const { ethers, upgrades } = require('hardhat');
const {arguments} = require("./arguments")

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    //EquityAllocation
    const EAAllocation = await ethers.getContractFactory("EquityAllocation");
    const hash = await upgrades.deployProxy(EAAllocation,  [
      "0x79D903745Fc78C4644aa481d4ECd4665e04De413", //equityToken
      "0x31B1B28A40d587A933f04402137Bec76e102A344", //tokenTreasury
      1000, //cxoAllocation
      800,  //seniorManagerAllocation
      400, //otherAllocation
      120, //Vesting period in seconds
      25, //cxoReleasePercent
      25, //seniorManagerPercent
      50 //otherPercent
      ],{ initializer: 'initialize' });
    const EAAllocationContract = await hash.deployed({gasPrice: 200000000000});

    let EAAllocationImplementation = await upgrades.erc1967.getImplementationAddress(EAAllocationContract.address);
    console.log("Deployed: Upgradeable Proxy    : " + EAAllocationContract.address);
    console.log("Implementation                  : " + EAAllocationImplementation);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });