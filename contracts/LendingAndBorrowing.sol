// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./Oracle.sol";

/**
 * @title       Main contract where the actual lending and borrowing happens
 * @author      Prajwal Adhikari
 * @notice
 *
 * //How to build
 *
 */

contract LendingAndBorrowing {
    //Events

    event Deposit(address sender, address token, uint256 amount); //event for deposit

    event Withdraw(address receiver, address token, uint256 amount); //event for withdraw

    //mapping to track token deposited
    mapping(address => mapping(address => uint256)) public deposits;

    //mapping to track token borrowed
    mapping(address => mapping(address => uint256)) public borrows;

    mapping(address => address) public tokenToPriceFeed;

    //here we go

    //deposit

    /**
     * 1. use ERC20 interface to use transferFrom function because user is sending token amount to this contract.
     * 2. actually get the token
     * 3. check for the success
     * 4. update deposit mapping
     * 5. emit event
     */
    //we need which token is being deposited and what amount
    function lend(address token, uint256 amount) external {
        //get the token amount from user to this contract 1&2
        bool success = ERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        require(success, "DEPOSIT: Transfer Failed"); //3

        deposits[msg.sender][token] += amount; //4

        emit Deposit(msg.sender, token, amount); //5
    }

    //withdraw
    //before withdraw first we have to set up liquidation threshold and health factor

    //Get ETH Value of a Token using Price Feed
    function getEthValue(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            tokenToPriceFeed[token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (uint256(price) * amount) / 1e18;

        // Calculate the value of the token in Ether using the price from the price feed.
        // The price is expressed as the number of Wei (a fraction of an Ether) per token unit.
        // To get the value in Ether, multiply the token amount by the price and divide by 1e18 Wei (1 Ether).
    }

    //
    function getTokenValueFromEth(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            tokenToPriceFeed[token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return (amount * 1e18) / uint256(price);
        // Example: 500000000000000 ETH (Wei) per DAI <--- Price
        // Example: 5000 DAI <-- Amount
        // Formula: Amount(DAI) / Price(ETH/DAI) = DAI per ETH
        // Formula: 5000 DAI * 1e18 / 2.5 ETH = 2000 DAI per ETH
    }


    //Now we will get collateral value for an account
    function getAccountCollateralValue(address account) public view returns (uint256){
        //shit i dont know from where to check tokens in the contract
    }




    //Health factor = (total_collateral * liquidation threshold)/total_debt

    function HeathFactor(address account) public view returns (uint256) {
        // (uint256 collateralValueInEth, uint256 borrowedValueInEth) = getA
        //to do line 64 we need current eth value and using that we will get collateral value in eth and borrowed value in eth.
    }
}
