//const { ethers } = require("hardhat");
const dotenv = require('dotenv');
dotenv.config();

// scripts/index.js
async function main () {

    console.log('ResultSet', process.env.ALCHEMY_API_KEY);
    
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });