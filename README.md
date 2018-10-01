# Brainspace-ICO-contracts

Brainspace Initial coin offering is a key stage in proccess of launching world wide blockchain registry
of intellectual property rights, patents, licenses / licensing.

Special terms: \n
  ERC20 - Ethereum Request of Comments. 20 - unique identical number of the standard.
  CCE - Crowdsale Contract Extension. The extension is additional functional for managing ICO.

The following provides visibility into how Brainspace ICO contracts are organized:

1. ERC20.sol - Abstract interface of the standard token;

2. StandardToken.sol - ERC20 implementation;

3. Lifecycle.sol - CCE for managing ICO lifecycle (for ex. stages, setting up conditions, stopping / continuing and etc.);

4. Ownable.sol - CCE for managing ICO and its functional as itself. Purposed for restriction access to special functions;

5. Rate.sol - CCE for managing ICO financial data (for ex. rates, percents, limits and etc.);

6. Verification.sol - CCE for managing validation and verification for users and accounts who want to make an investment.

7. IMPCoin.sol - Token contract. Describing all additional special data and logic for standard ERC20 token.

8. IMPCrowdsale.sol - Main crowdsale contract. Inherit all extensions and implement functional for token purchases.

9. SafeMath.sol - Library for safe math operations in other contracts.
