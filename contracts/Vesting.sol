// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract Vesting is Ownable, ReentrancyGuard, ERC20, VestingWallet {
   uint256 constant INITIAL_SUPPLY = 100 * 10**6 * 1e18; // 100 million
   address[] private benficiaryAddresses;

   uint256 private _released;

   constructor(
      string memory name,
      string memory symbol,
      address[] memory benficiaryAddress,
      uint64 startTimestamp
   )
      ERC20(name, symbol)
      VestingWallet(benficiaryAddress[0], startTimestamp, 365 days)
   {
      require (benficiaryAddress.length == 10, 'VestingWallet: should enter 10 addresses');
      _mint(address(this), INITIAL_SUPPLY);

      uint i = 0;
      for (i; i < 10; i ++) {
         benficiaryAddresses.push(benficiaryAddress[i]);
      }
   }

   function allBeneficiary() public view returns (address[] memory) {
      return benficiaryAddresses;
   }

   function released() public view virtual override returns (uint256) {
      return _released;
   }

   function transferToBenficiary(uint256 amount_) internal {
      uint8 i = 0;

      for (i; i < benficiaryAddresses.length; i ++) {
         _transfer(address(this), benficiaryAddresses[i], amount_);
      }
   }

   function release() public virtual override {
      uint256 releasable = vestedAmount(uint64(block.timestamp)) - released();
      _released += releasable;
      emit EtherReleased(releasable);
      
      transferToBenficiary(releasable / 10);
   }

   function vestedAmount(uint64 timestamp) public view virtual override returns (uint256) {
      return _vestingSchedule(balanceOf(address(this)) + released(), timestamp);
   }

   function _vestingSchedule(
      uint256 totalAllocation, 
      uint64 timestamp
   ) internal view virtual override returns (uint256) {
      if (timestamp < start()) {
         return 0;
      } else if (timestamp > start() + duration()) {
         return totalAllocation;
      } else {
         return (totalAllocation * (timestamp - start())) / duration();
      }
   }
}
