// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vesting is Ownable, ReentrancyGuard {
   event ERC20Released(address indexed token, uint256 amount);

   address[] private benficiary;
   uint256 private start;
   uint256 private duration = 365 days;
   mapping(address => uint256) private erc20Released;

   modifier whenNotEmptyAddress(address[] memory benficiaries_) {
      require(
         benficiaries_.length > 0,
         "VestingWallet: should have more than beneficiary address"
      );

      require(
         benficiaries_.length <= 10,
         "VestingWallet: can't be greater than 10 addresses"
      );

      uint8 i = 0;

      for (i; i < benficiaries_.length; i ++) {
         require(benficiaries_[i] != address(0), "VestingWallet: beneficiary is zero address");
      }
      _;
   }

   constructor(
      address[] memory benficiaries_,
      uint256 startTimestamp_
   ) whenNotEmptyAddress(benficiaries_) {
      require (startTimestamp_ >= block.timestamp, "VestingWallet: should later than now");
      benficiary = benficiaries_;
      start = startTimestamp_;
   }

   function getBeneficiary() public view  returns (address[] memory) {
      return benficiary;
   }

   function getStart() public view  returns (uint256) {
      return start;
   }

   function getDuration() public view  returns (uint256) {
      return duration;
   }

   function released(address token_) public view virtual returns (uint256) {
      return erc20Released[token_];
   }

   function transferToBenficiaries(address token_, uint256 releasable) internal {
      uint8 i = 0;

      for (i; i < benficiary.length; i ++) {
         SafeERC20.safeTransfer(IERC20(token_), benficiary[i], releasable);
      }
   }

   function release(address token_) public  {
      uint256 releasable = vestedAmount(token_, uint64(block.timestamp)) - released(token_);
      erc20Released[token_] += releasable;
      emit ERC20Released(token_, releasable);
      transferToBenficiaries(token_, releasable);
   }

   function vestedAmount(address token_, uint64 timestamp_) public view  returns (uint256) {
      return _vestingSchedule(IERC20(token_).balanceOf(address(this)) + released(token_), timestamp_);
   }

   function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view  returns (uint256) {
      if (timestamp < start) {
         return 0;
      } else if (timestamp > start + duration) {
         return totalAllocation;
      } else {
         return (totalAllocation * (timestamp - start)) / duration;
      }
   }

   receive() external payable  {}
}
