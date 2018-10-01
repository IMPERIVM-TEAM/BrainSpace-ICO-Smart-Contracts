pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 *      functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    //  The account who initially deployed both an IMPCoin and IMPCrowdsale contracts
    address public initialOwner;
    
    mapping(address => bool) owners;
    
    /**
     * Event for adding owner
     * @param admin is an account gonna be added to the admin list
     */
    event AddOwner(address indexed admin);
    
    /**
     * Event for deleting owner
     * @param admin is an account gonna be deleted from the admin list
     */
    event DeleteOwner(address indexed admin);
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwners() {
        require(
            msg.sender == initialOwner
            || inOwners(msg.sender)
        );
        _;
    }
    
    /**
     * @dev Throws if called by any account other than the initial owner.
     */
    modifier onlyInitialOwner() {
        require(msg.sender == initialOwner);
        _;
    }
    
    /**
     * @dev adding admin account to the admins list
     * @param _wallet is an account gonna be approved as an admin account
     */
    function addOwner(address _wallet) public onlyInitialOwner {
        owners[_wallet] = true;
        emit AddOwner(_wallet);
    }
    
    /**
     * @dev deleting admin account from the admins list
     * @param _wallet is an account gonna be deleted from the admins list
     */
    function deleteOwner(address _wallet) public onlyInitialOwner {
        owners[_wallet] = false;
        emit DeleteOwner(_wallet);
    }
    
    /**
     * @dev checking if account is admin or not
     * @param _wallet is an account for checking
     */
    function inOwners(address _wallet)
    public
    view
    returns(bool)
    {
        if(owners[_wallet]){ 
            return true;
        }
        return false;
    }
    
}