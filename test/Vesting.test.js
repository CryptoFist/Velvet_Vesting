const { expect } = require('chai');
const { ethers } = require('hardhat');

const bigNum = num=>(num + '0'.repeat(18))
const smallNum = num=>(parseInt(num)/bigNum(1))

describe('Vesting Contract', function () {
   before (async function () {
      [
         this.owner,
         this.addr1,
         this.addr2,
         this.addr3,
         this.addr4,
         this.addr5,
         this.addr6,
         this.addr7,
         this.addr8,
         this.addr9,
         this.addr10
      ] = await ethers.getSigners();

      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore.timestamp;

      this.vestingContract = await ethers.getContractFactory('Vesting');
      this.vestingContract = await this.vestingContract.deploy(
         'xyz',
         'XYZ',
         [
            this.addr1.address,
            this.addr2.address,
            this.addr3.address,
            this.addr4.address,
            this.addr5.address,
            this.addr6.address,
            this.addr7.address,
            this.addr8.address,
            this.addr9.address,
            this.addr10.address
         ],
         timestampBefore + 1000 * 60   // will starts after 1 minute 

      );
      await this.vestingContract.deployed();
   })

   it ('check balance of owner', async function () {
      let ownerBalance = await this.vestingContract.balanceOf(this.vestingContract.address);
      ownerBalance = smallNum(ownerBalance);
      expect(ownerBalance).to.equal(100 * 10**6);
   })

   it ('release and check before vesting is started', async function () {
      await this.vestingContract["release()"]();
      let released = await this.vestingContract["released()"]();
      released = smallNum(released);

      expect(released).to.be.equal(0);
   })

   it ('release and check released amount', async function () {
      await network.provider.send("evm_increaseTime", [1000 * 60 * 2]);
      await network.provider.send("evm_mine");

      await this.vestingContract["release()"]();
      let released = await this.vestingContract["released()"]();
      released = smallNum(released);

      expect(released).to.be.greaterThan(0);
   })

   it ('release and check released amount after finished vesting', async function () {
      await network.provider.send("evm_increaseTime", [1000 * 60 * 60 * 24 * 365]);
      await network.provider.send("evm_mine");

      await this.vestingContract["release()"]();
      let released = await this.vestingContract["released()"]();
      released = smallNum(released);

      expect(released).to.be.equal(100 * 10**6);
   })

})