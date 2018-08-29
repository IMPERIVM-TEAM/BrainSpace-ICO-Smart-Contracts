pragma solidity ^0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC20/StandardToken.sol";

/**
 * @title IMPCoin
 *
 * @dev Implementation of the standard ERC20 token
 * specified for our crowdsale conditions and needs.
 */
contract IMPCoin is StandardToken {

    using SafeMath for uint;
    
    string public name = "IMPCoin";
    string public symbol = "IMP";

    //  How much decimal signs in IMPCoin token.
    //  For ex., the smallest existing token amount in the case is 0.000001 IMP
    uint8 public decimals = 6;
    
    address owner;
    
    /*
     * @dev IMPCoin contract constructor
     * @param _initialSupply total amount of whole IMPCoin tokens existing since Brainspace ICO started
     */
    constructor(uint _initialSupply) public {
        totalSupply_ = _initialSupply * 10 ** uint(decimals);
        owner = msg.sender;
        balances[owner] = balances[owner].add(totalSupply_);
    }
}  