// scripts/upgrade_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const Hash = await ethers.getContractFactory('EquityAllocation');
  console.log('Upgrading contract...');
  await upgrades.upgradeProxy('0x2ab1a9108634F4cA5440932c0BE279E354ceEc71', Hash);
  console.log('Contract upgraded');
}

main();