pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
    address public initialOwner;
    address[] public owners;
    
    /**
     * @dev Throws if called by any account other than the owner accounts.
     */
    modifier onlyOwners() {
        require(
            msg.sender == initialOwner
            || inOwners(msg.sender)
        );
        _;
    }
    
    /**
     * @dev Throws if called by any account other than the main initial owner.
     */
    modifier onlyInitialOwner() {
        require(msg.sender == initialOwner);
        _;
    }
    
    /**
     * @dev Adding owner account to list of owners.
     * Available only for initial owner.
     * @param _wallet address of account to add.
     */
    function addOwner(address _wallet) public onlyInitialOwner {
        require(owners.length < 3);
        owners.push(_wallet);
    }
    
    /**
     * @dev Deleting owner account from list of owners.
     * Available only for initial owner.
     * @param _wallet address of account to delete.
     */
    function deleteOwner(address _wallet) public onlyInitialOwner {
        require(owners.length > 0);
        pop(_wallet);
    }
    
    /**
     * @dev Check if specified address refers to list of owners.
     * @param _wallet address of account to check.
     */
    function inOwners(address _wallet) private view returns(bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (_wallet == owners[i]) return true;
        }
        return false;
    }
    
    /**
     * @dev Low-level delete method for deleteOwner function.
     * @param _wallet address of account to delete.
     */
    function pop(address _wallet) private {
        for(uint index = 0; index < owners.length; index++) {
            if (_wallet == owners[index]) {
                delete owners[index];
                for(uint i = index + 1; i < owners.length; i++) {
                    owners[i - 1] = owners[i];
                }
                owners.length -= 1;
                break;
            }
        }
    }
}