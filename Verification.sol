pragma solidity ^0.4.24;

import "./Ownable.sol";

/**
 * @title Verification means
 * @dev The contract purposed for validating ethereum accounts
 *      able to buy IMP Coin
 */
contract Verification is Ownable {
    
    /**
     * Event for adding buyer
     * @param buyer is a new buyer
     */
    event AddBuyer(address indexed buyer);
    
    /**
     * Event for deleting buyer
     * @param buyer is a buyer gonna be deleted
     * @param success is a result of deleting operation
     */
    event DeleteBuyer(address indexed buyer, bool indexed success);
    
    mapping(address => bool) public approvedBuyers;
    
    /**
     * @dev adding buyer to the list of approved buyers
     * @param _buyer account gonna to be added
     */
    function addBuyer(address _buyer)
    public
    onlyOwners
    returns(bool success)
    {
        approvedBuyers[_buyer] = true;
        emit AddBuyer(_buyer);
        return true;
    }  
    
    /**
     * @dev deleting buyer from the list of approved buyers
     * @param _buyer account gonna to be deleted
     */
    function deleteBuyer(address _buyer)
    public
    onlyOwners
    returns(bool success)
    {
        if (approvedBuyers[_buyer]) {
            delete approvedBuyers[_buyer];
            emit DeleteBuyer(_buyer, true);
            return true;
        } else {
            emit DeleteBuyer(_buyer, false);
            return false;
        }
    }
    
    /**
     * @dev If specified account address is in approved buyers list
     *      then the function returns true, otherwise returns false
     */
    function getBuyer(address _buyer) public view  returns(bool success){
        if (approvedBuyers[_buyer]){
            return true;  
        }
        return false;        
    }
    
}