pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./Lifecycle.sol";
import "./IMPCoin.sol";
import "./Verification.sol";

/**
 * @dev Brainspace crowdsale contract
 */
contract IMPCrowdsale is Lifecycle, Verification {

    using SafeMath for uint;
     
    //  Token contract for the Crowdsale
    IMPCoin public token;
    
    //  Total amount of received wei
    uint public weiRaised;
    
    //  Total amount of sold tokens
    uint public totalSold;
    
    //  The variable is purposed for ETHUSD updating
    uint lastTimeStamp;
    
    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        uint value,
        uint amount
    );
    
    /**
     * Event for token purchase logging
     * @param rate new rate
     */
    event StringUpdate(string rate);
    
    
    /**
     * Event for manual token transfer
     * @param to receiver address
     * @param value tokens amount
     */
    event ManualTransfer(address indexed to, uint indexed value);

    constructor(
        IMPCoin _token,
        uint _cents,
        uint _requiredDollarAmount
    )
    public
    {
        require(_token != address(0));
        token = _token;
        initialOwner = msg.sender;
        setUpConditions( _cents, _requiredDollarAmount);
        crowdsaleStage = Stages.Private;
        updateCourse(); // comment out for the tests
    }
    
    /**
     * @dev callback
     */
    function () public payable {
        initialOwner.transfer(msg.value);
    }
    
    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     */
    function buyTokens()
    public
    payable
    appropriateStage
    {
        require(approvedBuyers[msg.sender]);
        require(totalSold <= token.totalSupply().div(100).mul(percentLimit));

        uint weiAmount = msg.value;
        _preValidatePurchase(weiAmount);

        // calculate token amount to be created
        uint tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(tokens);
        
        emit TokenPurchase(
            msg.sender,
            weiAmount,
            tokens
        );

        _forwardFunds();
        _postValidatePurchase(tokens);
    }
    
    /**
     *  @dev rate updating means 
     */
    function updateCourse() public payable onlyOwners {
        updatePrice();
        lastTimeStamp = now;
    }
    
    /**
     * @dev manual ETHUSD rate updating according to exchange data
     * @param _rate is the rate gonna be set up
     */
    function stringCourse(string _rate) public payable onlyOwners {
        stringUpdate(_rate);
        lastTimeStamp = now;
        emit StringUpdate(_rate);
    }
    
    function manualTokenTransfer(address _to, uint _value)
    public
    onlyOwners
    returns(bool success)
    {
        if(approvedBuyers[_to]) {
            totalSold = totalSold.add(_value);
            token.transferFrom(initialOwner, _to, _value);
            emit ManualTransfer(_to, _value);
            return true;    
        } else {
            return false;
        }
    }
    
    function _preValidatePurchase(uint _weiAmount)
    internal
    view
    {
        require(
            _weiAmount >= requiredWeiAmount,
            "Your investment funds are less than minimum allowable amount for tokens buying"
        );
    }
    
    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     */
    function _postValidatePurchase(uint _tokensAmount)
    internal
    {
        totalSold = totalSold.add(_tokensAmount);
    }
    
    /**
     * @dev Get tokens amount for purchasing
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint _weiAmount)
    internal
    view
    returns (uint)
    {
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        uint microTokenWeiPrice = centsWei.mul(usCentsPrice).div(10 ** uint(token.decimals()));
        uint amountTokensForInvestor = _weiAmount.div(microTokenWeiPrice);
        
        return amountTokensForInvestor;
    }
    
    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(uint _tokenAmount) internal {
        token.transferFrom(initialOwner, msg.sender, _tokenAmount);
    }
    
    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(uint _tokenAmount) internal {
        _deliverTokens(_tokenAmount);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        initialOwner.transfer(msg.value);
    }
    
    function destroy() public onlyInitialOwner {
        selfdestruct(this);
    }
}