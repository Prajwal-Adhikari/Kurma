// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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

    event Deposit(address sender, address token, uint256 amount);

    //mapping to track token deposited
    mapping(address => mapping(address => uint256)) public deposits;

    //mapping to track token borrowed
    mapping(address => mapping(address => uint256)) public borrows;

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

        emit Deposit(msg.sender, token, amount);    //5
    }
}
