// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//ERC20 interface

interface IERC20{

    //Functions

    function totalSupply() external view returns(uint256);   // returns total supply of a token.

    function balanceOf(address account) external view returns(uint256); //returns balance of a the address account.

    function transfer(address receiver, uint256 amount) external returns(bool); // transfer amount "amount" from the smart contract to the address receiver. return true if successful.

    function allowance(address owmer, address spender) external view returns(uint256); //returns amount approved by the owner to spend on their behalf.

    function approve(address spender, uint256 amount) external returns(bool); //returns true if setting of the token amount for a spender to spend on the behalf of owner is successful.

    function transferFrom(address sender, address receiver, uint256 amount) external returns(bool); //transfers approved amount from one account "sender" to another account "receiver" as long as the owner has authorized the sender.

    //Events

    event Approval(address indexed owner,address indexed spender,uint256 amount); // emitted when approval for spending "amount" amount of token by the spender on the behalf of the owner. Real use cases might be notifying smart contracts or third party involved.

    event Transfer(address indexed from, address indexed to, uint256 amount); //emitted when some amount of token is transferred from one account to another to smart contract or involved third parties.

}