const { parseEther } = require('ethers/lib/utils');
const { ethers } = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  nftContract = await ethers.getContractFactory('Vesting');
  const benficiary = '0x893f9805dB7a4E92cdC6Dbf14C9bfF90964b684a';
  this.vestingContract = await ethers.getContractFactory('Vesting');
   this.vestingContract = await this.vestingContract.deploy(
      'xyz',
      'XYZ',
      [
         benficiary, benficiary, benficiary, benficiary, benficiary, 
         benficiary, benficiary, benficiary, benficiary, benficiary
      ],
      timestampBefore + 1000 * 60   // will starts after 1 minute 

   );
   await this.vestingContract.deployed();
   console.log("vestingContract contract address:", this.vestingContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });