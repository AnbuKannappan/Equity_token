pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";


contract VirtualEquityToken is ERC20, Ownable { 
    constructor() ERC20("VirtualEquityToken", "VET") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    event MINT(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
        );

    function mint(
        address _to, 
        uint256 _value
    ) 
        external 
        onlyOwner
        returns (bool) 
    {
        _mint(_to,_value);
        emit MINT(msg.sender, _to, _value);
        return true;
    }
}
