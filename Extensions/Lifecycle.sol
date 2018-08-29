pragma solidity ^0.4.24;


import "./Rate.sol";
import "./Ownable.sol";

/**
 * @title Lifecycle
 * @dev The contract provides means for tracking
 * ICO lifecycle, switching stages and setting up
 * conditions for next ICO stage.
 */
contract Lifecycle is Ownable, Rate {
    /**
     * @dev Enumeration describing all crowdsale stages
     * Private for small group of privileged investors
     * PreSale for more wide and less privileged group of investors
     * Sale for all buyers
     * Cancel crowdsale completing stage
     * Stopped special stage for updates and force-major handling
     */
    enum Stages {
        Private,
        PreSale,
        Sale,
        Cancel,
        Stopped
    }
    
    //  Num of days for the current ICO stage
    uint public daysDuration;
    
    //  Previous crowdsale stage
    Stages public previousStage;
    
    //  Current crowdsale stage
    Stages public crowdsaleStage;
    
    //  Event for crowdsale stopping
    event ICOStopped(uint timeStamp);
    
    //  Event for crowdsale continuing after stopping
    event ICOContinued(uint timeStamp);
    
    //  Event for crowdsale starting
    event CrowdsaleStarted(uint timeStamp);
    
    /**
    * Event for ICO stage switching
    * @param timeStamp time of switching
    * @param newDuration amount of days for new stage
    * @param newPrice one token price (US cents)
    * @param newRequiredDollarAmount new minimum limit for investment
    */
    event ICOSwitched(
        uint timeStamp,
        uint newDuration,
        uint newPrice,
        uint newRequiredDollarAmount
    );
    
    modifier appropriateStage() {
        require(
            crowdsaleStage != Stages.Cancel,
            "ICO is finished now"
        );
        
        require(
            crowdsaleStage != Stages.Stopped,
            "ICO is temporary stopped at the moment"
        );
        _;
    }
    
    /**
     * @dev Stopping crowdsale process
     * Available only for contract owner.
     * Works only if current ICO stage
     * is not Stopped or Cancel.
     */
    function stopCrowdsale()
    public
    onlyOwners
    {
        require(crowdsaleStage != Stages.Stopped);
        previousStage = crowdsaleStage;
        crowdsaleStage = Stages.Stopped;
        
        emit ICOStopped(now);
    }
    
    /**
     * @dev Continuing crowdsale process
     * Available only for contract owner.
     * Works only if current ICO stage
     * is Stopped.
     */
    function continueCrowdsale()
    public
    onlyOwners
    {
        require(crowdsaleStage == Stages.Stopped);
        crowdsaleStage = previousStage;
        previousStage = Stages.Stopped;
        
        emit ICOContinued(now);
    }
    
    /*
     * @dev Switching ICO stage and redefining key parameters for the next stage
     * @param _duration Time period in days for particular ICO stage
     * @param _cents One token cost in U.S. cents
     * @param _requiredDollarAmount Minimal dollar amount whicn Investor can send for buying purpose
     */
    function nextStage(
        uint _duration,
        uint _cents,
        uint _requiredDollarAmount
    )
    public
    onlyOwners
    appropriateStage
    {
        crowdsaleStage = Stages( uint(crowdsaleStage) + 1 );
        setUpConditions(_duration, _cents, _requiredDollarAmount);
        updatePrice();
        
        emit ICOSwitched(now, _duration, _cents, _requiredDollarAmount);
    }
    
    /**
     * @dev Setting up specified parameters for particular ICO stage
     * @param _duration Time period in days for particular ICO stage
     * @param _cents One token cost in U.S. cents
     * @param _requiredDollarAmount Minimal dollar amount whicn Investor can send for buying purpose
     */
    function setUpConditions(
        uint _duration,
        uint _cents,
        uint _requiredDollarAmount
    )
    internal
    {
        require(_duration > 0);
        require(_cents > 0);
        require(_requiredDollarAmount > 0);
        
        daysDuration = _duration;
        usCentsPrice = _cents;
        requiredDollarAmount = _requiredDollarAmount;
    }
}