// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol";  //importing our interface for ERC20 tokens

contract LpToken is IERC20{
    string public name;     //name of the ERC20 token e.g. ether
    string public symbol;   //symbol of the ERC20 token e.g. ETH
    uint256 private _totalSupply;   //total supply of LpToken. It is not necessary to make it public so we keep it private.

    constructor(string memory _name,string memory _symbol,uint256 _initialSupply){
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;

    }
}