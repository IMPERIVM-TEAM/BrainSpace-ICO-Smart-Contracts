pragma solidity ^0.4.24;

import "./Rate.sol";
import "./Ownable.sol";

/**
 * @title Lifecycle means
 * @dev The contract purposed for managing crowdsale lifecycle
 */
contract Lifecycle is Ownable, Rate {
    
    /**
     * Enumeration describing all crowdsale stages
     * @ Private for small group of privileged investors
     * @ PreSale for more wide and less privileged group of investors
     * @ Sale for all buyers
     * @ Cancel crowdsale completing stage
     * @ Stopped special stage for updates and force-major handling
     */
    enum Stages {
        Private,
        PreSale,
        Sale,
        Cancel,
        Stopped
    }
    
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
    * @param newPrice one token price (US cents)
    * @param newRequiredDollarAmount new minimum limit for investment
    */
    event ICOSwitched(uint timeStamp,uint newPrice,uint newRequiredDollarAmount);
    
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
    
    function stopCrowdsale()
    public
    onlyOwners
    {
        require(crowdsaleStage != Stages.Stopped);
        previousStage = crowdsaleStage;
        crowdsaleStage = Stages.Stopped;
        
        emit ICOStopped(now);
    }
    
    function continueCrowdsale()
    public
    onlyOwners
    {
        require(crowdsaleStage == Stages.Stopped);
        crowdsaleStage = previousStage;
        previousStage = Stages.Stopped;
        
        emit ICOContinued(now);
    }
    
    function nextStage(
        uint _cents,
        uint _requiredDollarAmount
    )
    public
    onlyOwners
    appropriateStage
    {
        crowdsaleStage = Stages(uint(crowdsaleStage)+1);
        setUpConditions( _cents, _requiredDollarAmount);
        emit ICOSwitched(now,_cents,_requiredDollarAmount);
    }
    
    /**
     * @dev Setting up specified parameters for particular ICO stage
     * @param _cents One token cost in U.S. cents
     * @param _requiredDollarAmount Minimal dollar amount whicn Investor can send for buying purpose
     */
    function setUpConditions(
        uint _cents,
        uint _requiredDollarAmount
    )
    internal
    {
        require(_cents > 0);
        require(_requiredDollarAmount > 0);
        
        percentLimit =  percentLimits[ uint(crowdsaleStage) ];
        usCentsPrice = _cents;
        requiredDollarAmount = _requiredDollarAmount;
    }
    
}