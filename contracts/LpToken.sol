// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol"; //importing our interface for ERC20 tokens

contract LpToken is IERC20 {
    string public name; //name of the ERC20 token e.g. ether
    string public symbol; //symbol of the ERC20 token e.g. ETH
    uint256 private _totalSupply; //total supply of LpToken. It is not necessary to make it public so we keep it private.

    //mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    //Implement all the functionalities defined in IERC20 token standard

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address _account
    ) public view override returns (uint256) {
        return _balances[_account];
    }

    function transfer(
        address _receiver,
        uint256 _amount
    ) public override returns (bool) {
        //check if funds are going to 0 address or non existing address
        require(_receiver != address(0), "Cannot transfer to zero address");
        //check if sender has sufficient balance
        require(
            _balances[msg.sender] >= _amount,
            "Transfer failed! Insufficient funds"
        );

        //deduce _amount from deployer account
        _balances[msg.sender] -= _amount;

        //add this _amount to the _receiver account
        _balances[_receiver] += _amount;

        // we need to emit an event notifying that transfer has been succeeded. So we used our Transfer event
        emit Transfer(msg.sender, _receiver, _amount);

        //After all these steps are successful i.e. transfer of fund is done we return true .. bool -> true
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256) {
        return _allowed[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 _amount
    ) public override returns (bool) {
        _allowed[msg.sender][_spender] = _amount; //since the approve function is called by the owner which is then msg.sender we have msg.sender and then only spender when we deal with our _allowed mapping.

        //after allowance is done we emit the Approval event
        emit Approval(msg.sender, _spender, _amount);

        //return true if everything goes as planned
        return true;
    }

    function transferFrom(
        address _sender,
        address _receiver,
        uint256 _amount
    ) public override returns (bool) {
        //checks needed
        /*
            sender and receiver address must not be zero or invalid address

            senders account funds should be equal or greate the amount that they are trying to transfer to the receiver

            sender should have sufficeient allowance approved by the owner
         */

        require(_sender != address(0),"Sender address does not exists"); //checks if null address is transerring funds

        require(_receiver != address(0), "Receiver address does not exists");

        require(_balances[_sender] >= _amount, "Transfer failed: Insufficient funds");

        require(_allowed[_sender][msg.sender] >= _amount, "Insufficient allowance");


        //lets do some simple maths

        //deduct amount from sender side
        _balances[_sender] -= _amount;

        //add amount in the receiver account
        _balances[_receiver] += _amount;

        //make sure to deduct the allowance for the sender
        _allowed[_sender][msg.sender] -= _amount;

        //All done now emit the Transfer event
        emit Transfer(_sender,_receiver,_amount);

        //if success
        return true;


    }
}
