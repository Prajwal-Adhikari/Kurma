// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceOracle {
    // Declare a variable to store the price feed interface
    AggregatorV3Interface internal priceFeed;

    // Constructor function that initializes the contract with the price feed address
    constructor(address _priceFeedAddress) {
        // Create a new instance of the AggregatorV3Interface using the provided address
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    // Public function to retrieve the latest price value from the price feed
    function getLatestPrice() public view returns (int256) {
        // Call the latestRoundData function of the price feed to retrieve the latest price data
        // The function returns a tuple with five values, but we only care about the second value (the current price value)
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // Return the current price value as an int256
        return price;
    }
}
