
pragma solidity ^0.8.2;
pragma abicoder v2;

/**
 * @title EATypes
 * @author
 *
 */
library EATypes {
  
  struct RoleAllocationInit {
        bytes32 role;
        uint256 equity;
        bool check;
        uint128 vestPercent;
  }
    
  struct UserGrantAllocation {
        bytes32 role;
        uint256 timestamp;
        uint256 initialEquityAllocation;
        uint256 totalBalanceEquity;
        uint256 unlockedEquity;
        uint256 lockedEquity;
        uint256 vestedRatio;
  }
  
}
