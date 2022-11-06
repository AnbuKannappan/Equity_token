// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.2;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import {EARoles} from './EARoles.sol';
import {EATypes} from './EATypes.sol';

/**
 * @title EquityAllocation
 * @author 
 *
 */
contract EquityAllocation is 
 Initializable,
 EARoles,
 ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address private etToken;
    address private treasuryAccount;
    uint256 private vestingPeriod;

    uint256 private constant MIN_VESTING_PERIOD = 2 minutes;
    
    mapping(bytes32 => EATypes.RoleAllocationInit) internal _allocationList;
    mapping(address => EATypes.UserGrantAllocation) internal _userBalance;

    //events
    event TokenAllocation(bytes32 indexed role, address indexed account, uint256 indexed AmountAllocated);

    event VestingPeriodUpdated(address indexed account, uint256 indexed NewVestingPeriod);

    event UserUnlockedEquity(address indexed account, bytes32 indexed role, uint256 indexed UnlockedAmount);

    event UserWithdrawalUnlockedEquity(address indexed account, bytes32 indexed role, uint256 indexed WithdrawalAmount);
    // ============ External Functions ============

    function initialize(
        address equityToken,
        address tokenTreasury,
        uint256 cxoAllocation,
        uint256 seniorManagerAllocation,
        uint256 otherAllocation,
        uint256 vestPeriod,
        uint128 cxoReleasePercent,
        uint128 seniorManagerPercent,
        uint128 otherPercent
    )
        external
        initializer
    {
        __EARoles_init();
        __RolesAllocation_init(
            cxoAllocation, 
            seniorManagerAllocation, 
            otherAllocation, 
            cxoReleasePercent, 
            seniorManagerPercent,
            otherPercent);
        etToken = equityToken;
        vestingPeriod = vestPeriod;
        treasuryAccount = tokenTreasury;
    }

    function grantToken( 
        bytes32 role,
        address account
    ) 
        external 
        onlyRole(OWNER_ROLE)
        returns (bool) 
    {
        
        require( hasRole(role, account), "Invalid Role");
        
        _userBalance[account] = EATypes.UserGrantAllocation({
            role: role,
            timestamp: block.timestamp,
            initialEquityAllocation: _allocationList[role].equity * 10 **18,
            totalBalanceEquity: _allocationList[role].equity * 10 **18,
            unlockedEquity: 0,
            lockedEquity: _allocationList[role].equity * 10 **18,
            vestedRatio: 0
        });

        emit TokenAllocation(role, account, _allocationList[role].equity * 10 **18);

        return true;
    }

    function updateVestingPeriod( 
        uint256 newVestingPeriod
    )
        external
        onlyRole(OWNER_ROLE)
        returns (bool)
    {
        require( newVestingPeriod > MIN_VESTING_PERIOD, "Invalid vesting period");
        vestingPeriod = newVestingPeriod;
        emit VestingPeriodUpdated(msg.sender, newVestingPeriod);
        return true;
    }

    function unlockEquity(
    )
        external
        nonReentrant
        returns (bool)
    {
        return _unlockEquity(msg.sender);
    }

    function withdrawUnlockedEquity(
    )
        external
        nonReentrant
        returns (bool)
    {
        return _withdrawUnlockedEquity(msg.sender);
    }

    function _withdrawUnlockedEquity(
        address account
    )
        internal
        returns (bool)
    { 
        require( hasRole(_userBalance[account].role, account), "Invalid Role");
        require(account != address(0), 'LS1ERC20: Transfer from address(0)');

        uint withdrawalEquity = _userBalance[account].unlockedEquity;
        _userBalance[account].totalBalanceEquity = _userBalance[account].totalBalanceEquity - _userBalance[account].unlockedEquity;
        _userBalance[account].unlockedEquity = 0;
        IERC20Upgradeable(etToken).safeTransferFrom(treasuryAccount,account, withdrawalEquity);

        emit UserWithdrawalUnlockedEquity(account, _userBalance[account].role,withdrawalEquity);
        return true;
    }

    function _unlockEquity(
        address account
    )
        internal
        returns (bool)
    {   
        require( hasRole(_userBalance[account].role, account), "Invalid Role");
        
        
        uint256 eligibleRatio = ((block.timestamp - _userBalance[account].timestamp)/ vestingPeriod) - _userBalance[account].vestedRatio;
        uint256 eligiblePercent = eligibleRatio * _allocationList[_userBalance[account].role].vestPercent;

        if(eligiblePercent > 100) {
            eligiblePercent = 100;
        }
        require(eligibleRatio != 0, 'Not eligible for unlock');
        require(_userBalance[account].lockedEquity >= (_userBalance[account].initialEquityAllocation *  eligiblePercent) / 100, 'Equity unlock exceeded');

        _userBalance[account].vestedRatio = _userBalance[account].vestedRatio + eligibleRatio;
        _userBalance[account].unlockedEquity = _userBalance[account].unlockedEquity + ((_userBalance[account].initialEquityAllocation *  eligiblePercent) / 100);
        _userBalance[account].lockedEquity = _userBalance[account].lockedEquity - ((_userBalance[account].initialEquityAllocation *  eligiblePercent) / 100);

        emit UserUnlockedEquity(account, _userBalance[account].role, _userBalance[account].unlockedEquity);
        return true;
    }

    function getUserBalanceLockedEquity(
        address account
    )
        external
        view
        returns (uint256)
    {
        return _userBalance[account].lockedEquity;
    }

    function getUserBalanceUnlockedEquity(
        address account
    )
        external
        view
        returns (uint256)
    {
        return _userBalance[account].unlockedEquity;
    }

    function getUserBalanceTotalEquity(
        address account
    )
        external
        view
        returns (uint256)
    {
        return _userBalance[account].totalBalanceEquity;
    }

    function __RolesAllocation_init(
        uint256 cxoAllocation, 
        uint256 seniorManagerAllocation,
        uint256 otherAllocation,
        uint128 cxoReleasePercent,
        uint128 seniorManagerPercent,
        uint128 otherPercent
    ) 
        internal 
    {
        _allocationList[CXO_ROLE] = EATypes.RoleAllocationInit({
                role: CXO_ROLE,
                equity: cxoAllocation,
                check: true,
                vestPercent: cxoReleasePercent
            });
        _allocationList[SENIOR_MANAGER_ROLE] = EATypes.RoleAllocationInit({
                role: SENIOR_MANAGER_ROLE,
                equity: seniorManagerAllocation,
                check: true,
                vestPercent: seniorManagerPercent
            });
        _allocationList[OTHER_ROLE] = EATypes.RoleAllocationInit({
                role: OTHER_ROLE,
                equity: otherAllocation,
                check: true,
                vestPercent: otherPercent
            });
    }   

}