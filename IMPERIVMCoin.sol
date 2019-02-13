pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./StandardToken.sol";

/**
 * @title IMPCoin implementation based on ERC20 standard token
 */
contract IMPERIVMCoin is StandardToken {
    
    using SafeMath for uint;
    
    string public name = "IMPERIVMCoin";
    string public symbol = "IMPC";
    uint8 public decimals = 6;
    
    address owner;
    
    /**
     *  @dev Contract initiallization
     *  @param _initialSupply total tokens amount
     */
    constructor(uint _initialSupply) public {
        totalSupply_ = _initialSupply * 10 ** uint(decimals);
        owner = msg.sender;
        balances[owner] = balances[owner].add(totalSupply_);
    }
    
}  