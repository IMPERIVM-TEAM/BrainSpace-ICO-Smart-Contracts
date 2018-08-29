pragma solidity ^0.4.24;


import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

/**
 * @title Rate contract
 *
 * @dev The contract provides functional means for tracking
 * and updatingEther / USD exchange rate (in the case in US cents).
 * Also, this module provides functions for showing wei amount
 * investor need to pay for specified token amount,
 * and for showing token amount which investor can buy for
 * specified whole ethers or US cents.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract Rate is usingOraclize {
    
    using SafeMath for uint256;
    
    //  Ether / US cent exchange rate
    uint256 public ETHUSDC;
    
    //  Token price in US cents
    uint public usCentsPrice;
    
    //  Minimum wei amount derived from requiredDollarAmount parameter
    uint256 public requiredWeiAmount;
    
    //  Minimum dollar amount that investor can provide for purchasing
    uint256 public requiredDollarAmount;
    
    //  Event for interacting with OraclizeAPI
    event LogConstructorInitiated(string nextStep);
    
    //  Event for price updating
    event LogPriceUpdated(string price);
    
    //  Event for logging oraclize queries
    event LogNewOraclizeQuery(string description);
    
    /**
     * @dev Callback function for oraclizer.
     * Dedicated only for interacting with Oraclizer contract
     */
    function __callback(bytes32 myid, string result) public {
       if (msg.sender != oraclize_cbAddress()) revert();
       ETHUSDC = parseInt(result, 2);
       requiredWeiAmount = requiredDollarAmount.mul(100).mul(1 ether).div(ETHUSDC);
       emit LogPriceUpdated(result);
    }

    /**
     * @dev Request function for oraclizer.
     * Dedicated only for interacting with Oraclizer contract
     */
    function updatePrice() internal {
       if (oraclize_getPrice("URL") > address(this).balance) {
           emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
       } else {
           emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
           oraclize_query("URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");
       }
    }

    function stringUpdate(string _rate) internal {
        ETHUSDC = parseInt(_par, 0);
    }
    
    function parseInt(string _a, uint _b) private pure returns (uint) {
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
    
    /**
     * @dev Converting ether amount to token amount
     */
    function ethersToTokens(uint _ethAmount)
    public
    view
    returns(uint microTokens)
    {
        uint centsAmount = _ethAmount.mul(ETHUSDC);
        return centsToTokens(centsAmount);
    }
    
    /**
     * @dev Converting  US cent amount to token amount
     */
    function centsToTokens(uint _cents)
    public
    view
    returns(uint microTokens)
    {
        require(_cents > 0);
        microTokens = _cents.mul(1000000).div(usCentsPrice);
        return microTokens;
    }
    
    /**
     * @dev Converting microtoken amount to wei amount
     */
    function tokensToWei(uint _microTokensAmount)
    public
    view
    returns(uint weiAmount) {
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        //  .div( 10 ** 6 ) <-- There the six number is decimals number from token
        uint microTokenWeiPrice = centsWei.mul(usCentsPrice).div( 10 ** 6 );
        weiAmount = _microTokensAmount.mul(microTokenWeiPrice);
        return weiAmount;
    }
    
    /**
     * @dev Converting microtoken amount to US cent amount
     */
    function tokensToCents(uint _microTokenAmount)
    public
    view
    returns(uint centsAmount) {
        centsAmount = _microTokenAmount.mul(usCentsPrice).div(1000000);
        return centsAmount;
    }
}