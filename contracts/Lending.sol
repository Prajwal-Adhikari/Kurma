// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./UserLookUp.sol";

contract Lending is Ownable, ReentrancyGuard {
    //mappings
    //tokenaddress => user => amount
    mapping(address => mapping(address => uint256)) public tokensLent;
    mapping(address => mapping(address => uint256)) public tokensBorrowed;

    //for pricefeed
    mapping(address => address) public tokenToPriceFeed;

    //lenders and borrowers in the platform
    address[] public lenders;
    address[] public borrowers;

    //UserLookUp for address
    using UserLookUp for address;


    //I will implement stable rate for calculation of interest for this project

    struct Token {
        address tokenAddress;
        string name;
        uint256 stableRate;
        uint256 LTV;
    }

    //now i need a way in which the contract deployer can set the tokens for lending and borrowing
    Token[] public tokensForLending;
    Token[] public tokensForBorrowing;

    function addTokensForLending(
        address _tokenAddress,
        string memory _name,
        uint256 _stableRate,
        uint256 _LTV
    ) external onlyOwner {
        //create token from the function parameters
        Token memory token = Token(_tokenAddress, _name, _stableRate, _LTV);

        //check if the same token is already listed     we need a private function to check
        //if not already listed add token
        if (!checkTokenAlreadyListed(token, tokensForLending)) {
            tokensForLending.push(token);
        }
    }

    //same for addTokensForBorrowing

    function addTokensForBorrowing(
        address _tokenAddress,
        string memory _name,
        uint256 _stableRate,
        uint256 _LTV
    ) external onlyOwner {
        Token memory token = Token(_tokenAddress, _name, _stableRate, _LTV);

        if (!checkTokenAlreadyListed(token, tokensForBorrowing)) {
            tokensForBorrowing.push(token);
        }
    }

    function checkTokenAlreadyListed(
        Token memory token,
        Token[] memory tokenArray
    ) private pure returns (bool) {
        if (tokenArray.length > 0) {
            for (uint256 i = 0; i < tokenArray.length; i++) {
                if (tokenArray[i].tokenAddress == token.tokenAddress)
                    return true;
            }
        }
        return false;
    }


    /*
    lend
    borrow
    withdraw 
    repay
    liquidate
     */

    //lend
    function supply(address tokenAddress,uint256 amount) external payable{
        //check if the token is allowed for lending in the platform -> we need a private function for this

        require(isTokenAllowed(tokenAddress,tokensForLending),"LEND: Asset not supported");
        require(amount > 0,"LEND: Cannot lend 0 amount");


        IERC20 token = IERC20(tokenAddress);

        //check balance of user 
        require(token.balanceOf(msg.sender) >= amount,"Insufficient Funds");

        //transfer token amount from msg.sender(user here) to this smart contract;
        token.transferFrom(msg.sender,address(this),amount);

        (bool userIsAlreadyALender, int256 userIndex) = msg.sender.isUserPresentIn(lenders);

        if(userIsAlreadyALender){
            
        }

    }

    function isTokenAllowed(address tokenAddress, Token[] memory tokenArray) private pure returns(bool){
        if(tokenArray.length > 0){
            for(uint256 i = 0; i < tokenArray.length; i++){
                if(tokenArray[i].tokenAddress == tokenAddress){
                    return true;
                }
            }
        }
        return false;
    }

}
