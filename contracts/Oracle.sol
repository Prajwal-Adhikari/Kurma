// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract Oracle {

    //for oracle pricefeed
    mapping(address => address) public tokenToPriceFeed;
function oneTokenToDollars(
        address tokenAddress
    ) public view returns (uint256) {
        address thisToken = tokenToPriceFeed[tokenAddress];

        //declared as a new instance of the AggregatorV3Interface interface, which represents a specific price oracle contract.
        AggregatorV3Interface priceFeed = AggregatorV3Interface(thisToken);

        (, int256 price, , , ) = priceFeed.latestRoundData();

        return (uint256(price));
    }

    function getDollarEquivalentOfThisToken(
        address tokenAddress,
        uint256 amount
    ) public view returns (uint256) {
        uint256 dollarsPerToken = oneTokenToDollars(tokenAddress);

        uint256 totalAmountInDollars = (amount * dollarsPerToken);

        return totalAmountInDollars;
    }

}