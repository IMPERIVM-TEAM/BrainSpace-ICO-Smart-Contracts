pragma solidity ^0.4.24;


import "../Extensions//Lifecycle.sol";


//  Interface for interacting with IMPCoin contract
interface IMPCoin {
    // function safeTransferFrom(address _from, address _to, uint256 _amount);
    function transferFrom(address _from, address _to, uint256 _amount) external;
    function decimals() external returns(uint);
}


/**
 * @title Smart contract for Brainspace ICO
 * 
 */
contract IMPCrowdsale is Lifecycle {
    
    using SafeMath for uint;
    // using SafeERC20 for IMPCoin;
    
    //  Token contract for the Crowdsale
    IMPCoin public token;
    
    //  Total amount of received wei
    uint public weiRaised;
    
    //  Total amount of sold tokens
    uint public totalSold;
    
    uint public hardCapMicroTokens = 1431000000000000;
    
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
        uint256 value,
        uint256 amount
    );
    
    constructor(
        IMPCoin _token,
        uint _duration,
        uint _cents,
        uint _requiredDollarAmount
    )
    public
    {
        require(_token != address(0));
        token = _token;
        initialOwner = msg.sender;
        setUpConditions(_duration, _cents, _requiredDollarAmount);
        crowdsaleStage = Stages.Private;
        updateCourse();
        emit CrowdsaleStarted(now);
    }
    
    function () public payable {
        initialOwner.transfer(msg.value);
    }
    
    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     */
    function buyTokens() public payable {
        require(totalSold <= hardCapMicroTokens);

        uint256 weiAmount = msg.value;
        _preValidatePurchase(weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

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
  
    function _preValidatePurchase(uint256 _weiAmount)
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
    function _getTokenAmount(uint256 _weiAmount)
    internal
    view
    returns (uint256)
    {
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        uint microTokenWeiPrice = centsWei.mul(usCentsPrice).div(10 ** token.decimals());
        uint amountTokensForInvestor = _weiAmount.div(microTokenWeiPrice);
        
        return amountTokensForInvestor;
    }
    
    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(uint256 _tokenAmount) internal {
        token.transferFrom(initialOwner, msg.sender, _tokenAmount);
    }
    
    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(uint256 _tokenAmount) internal {
        _deliverTokens(_tokenAmount);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        initialOwner.transfer(msg.value);
    }
    
    function updateCourse()
    public
    payable
    onlyOwners
    {
        if (now.sub(lastTimeStamp) >= 120) {
            updatePrice();
            lastTimeStamp = now;
        }
    }

    function stringCourse(string _rate)
    public
    payable
    onlyOwners
    {
        if (now.sub(lastTimeStamp) >= 120) {
            stringUpdate(_rate);
            lastTimeStamp = now;
        }
    }
}