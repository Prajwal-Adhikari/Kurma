//SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//This token will be transferred to the lenders once they lend their token to the contract
contract LendToken is ERC20{

    uint256 initialMintAmount = 1000000 * 10e18;    //1 million; 18 decimal places precision.
    constructor() ERC20("Lend Token","LEN"){
        _mint(msg.sender,initialMintAmount);
    }
}