const { Contract, providers, utils, Wallet } = require("ethers");
const testTokenAbi = require("../abi/BavaCompaoundVault.json");

async function main () {
const rpc =  await new providers.JsonRpcProvider( "https://api.avax-test.network/ext/bc/C/rpc" ) ;
const wallet = new Wallet( "8aa1621c51c72c2ed353e08c0242855850e0712acf3ab1881e3ef87fb574fbd4", rpc);


const testTokenContract = new Contract("0x41Ae92E26aBb12292cc7eea6586f71DC3A4C47EC", testTokenAbi.abi, wallet);

let flag = await testTokenContract.deposit(BigInt(900000000000000000), "false");

console.log(flag);
}

main()