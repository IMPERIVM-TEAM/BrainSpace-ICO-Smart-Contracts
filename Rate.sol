pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

/**
 * @title Rate means
 * @dev The contract purposed for managing crowdsale financial data,
 *      such as rates, prices, limits and etc.
 */
contract Rate is usingOraclize {
    
    using SafeMath for uint;
    
    //  Ether / US cent exchange rate
    uint public ETHUSDC;
    
    //  Token price in US cents
    uint public usCentsPrice;
    
    //  Token price in wei
    uint public tokenWeiPrice;
    
    //  Minimum wei amount derived from requiredDollarAmount parameter
    uint public requiredWeiAmount;
    
    //  Minimum dollar amount that investor can provide for purchasing
    uint public requiredDollarAmount;

    //  Total tokens amount which can be sold at the current crowdsale stage
    uint internal percentLimit;

    //  All percent limits according to Crowdsale stages
    uint[] internal percentLimits = [10, 27, 53, 0];
    
    //  Event for interacting with OraclizeAPI
    event LogConstructorInitiated(string  nextStep);
    
    //  Event for price updating
    event LogPriceUpdated(string price);
    
    //  Event for logging oraclize queries
    event LogNewOraclizeQuery(string  description);

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHUSDC = parseInt(result, 2);
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        tokenWeiPrice = usCentsPrice.mul(centsWei);
        requiredWeiAmount = requiredDollarAmount.mul(100).mul(1 ether).div(ETHUSDC);
        emit LogPriceUpdated(result);
    }

    function ethersToTokens(uint _ethAmount)
    public
    view
    returns(uint microTokens)
    {
        uint centsAmount = _ethAmount.mul(ETHUSDC);
        return centsToTokens(centsAmount);
    }
    
    function centsToTokens(uint _cents)
    public
    view
    returns(uint microTokens)
    {
        require(_cents > 0);
        microTokens = _cents.mul(1000000).div(usCentsPrice);
        return microTokens;
    }
    
    function tokensToWei(uint _microTokensAmount)
    public
    view
    returns(uint weiAmount) {
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        uint microTokenWeiPrice = centsWei.mul(usCentsPrice).div(10 ** 6);
        weiAmount = _microTokensAmount.mul(microTokenWeiPrice);
        return weiAmount;
    }
    
    function tokensToCents(uint _microTokenAmount)
    public
    view
    returns(uint centsAmount) {
        centsAmount = _microTokenAmount.mul(usCentsPrice).div(1000000);
        return centsAmount;
    }
    
    function updatePrice() internal {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");
        }
    }

    function stringUpdate(string _rate) internal {
        ETHUSDC = getInt(_rate, 0);
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        tokenWeiPrice = usCentsPrice.mul(centsWei);
        requiredWeiAmount = requiredDollarAmount.mul(100).mul(1 ether).div(ETHUSDC);
    }
    
    function getInt(string _a, uint _b) private pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        return mint;
    }
    
}