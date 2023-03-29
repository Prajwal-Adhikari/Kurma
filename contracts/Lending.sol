// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Lending is Ownable, ReentrancyGuard{

    //mappings
    //tokenaddress => user => amount
    mapping(address => mapping(address => uint256)) public tokensLent;
    mapping(address => mapping(address => uint256)) public tokensBorrowed;

    //for pricefeed
    mapping(address => address) public tokenToPriceFeed;


    //lenders and borrowers in the platform
    address[] public lenders;
    address[] public borrowers;



    //I will implement stable rate for calculation of interest for this project


    struct Token{
        address tokenAddress;
        string name;
        uint256 stableRate;
        address LTV;
    }

    //now i need a way in which the contract deployer can set the tokens for lending and borrowing.abi
    

}