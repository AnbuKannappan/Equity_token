
pragma solidity ^0.8.2;
pragma abicoder v2;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title EARoles
 * @author
 *
 */
abstract contract EARoles is AccessControl

{
  bytes32 public constant OWNER_ROLE = keccak256('OWNER_ROLE');
  bytes32 public constant CXO_ROLE = keccak256('CXO_ROLE');
  bytes32 public constant SENIOR_MANAGER_ROLE = keccak256('SENIOR_MANAGER_ROLE');
  bytes32 public constant OTHER_ROLE = keccak256('OTHER_ROLE');

  //bytes32 [] private _roleCheck = [CXO_ROLE, SENIOR_MANAGER_ROLE, OTHER_ROLE];

  function __EARoles_init() internal {
    _setupRole(OWNER_ROLE, msg.sender);
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

    // Set OWNER_ROLE as the admin of all roles.
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    _setRoleAdmin(DEFAULT_ADMIN_ROLE, OWNER_ROLE);
    _setRoleAdmin(CXO_ROLE, OWNER_ROLE);
    _setRoleAdmin(SENIOR_MANAGER_ROLE, OWNER_ROLE);
    _setRoleAdmin(OTHER_ROLE, OWNER_ROLE);
  }


}
