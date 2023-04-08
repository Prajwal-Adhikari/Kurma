// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./UserLookUp.sol";
import "./Oracle.sol";

contract Lending is Ownable, ReentrancyGuard {
    //mappings
    //tokenaddress => user => amount
    mapping(address => mapping(address => uint256)) public tokensLentAmount;
    mapping(address => mapping(address => uint256)) public tokensBorrowedAmount;

    mapping(uint256 => mapping(address => address)) public tokensLent;
    mapping(uint256 => mapping(address => address)) public tokensBorrowed;

    //lenders and borrowers in the platform
    address[] public lenders;
    address[] public borrowers;

    //UserLookUp for address
    using UserLookUp for address;
    Oracle public oracle;

    uint256 public noOfTokensLent = 0;
    uint256 public noOfTokensBorrowed = 0;

    IERC20 public LendCoin;

    //I will implement stable rate for calculation of interest for this project

    constructor(address _tokenAddress) {
        LendCoin = IERC20(_tokenAddress);
    }

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
    function supply(address tokenAddress, uint256 amount) external payable {
        //check if the token is allowed for lending in the platform -> we need a private function for this

        require(
            isTokenAllowed(tokenAddress, tokensForLending),
            "LEND: Asset not supported"
        );
        require(amount > 0, "LEND: Cannot lend 0 amount");

        IERC20 token = IERC20(tokenAddress);

        //check balance of user
        require(token.balanceOf(msg.sender) >= amount, "Insufficient Funds");

        //transfer token amount from msg.sender(user here) to this smart contract;
        token.transferFrom(msg.sender, address(this), amount);

        (bool userIsAlreadyALender, int256 userIndex) = msg
            .sender
            .isUserPresentIn(lenders);

        if (userIsAlreadyALender) {
            updateUserTokensBorrowedOrLent(
                tokenAddress,
                amount,
                userIndex,
                "lenders"
            );
        } else {
            lenders.push(msg.sender);
            tokensLentAmount[tokenAddress][msg.sender] = amount;
            tokensLent[noOfTokensLent++][msg.sender] = tokenAddress;
        }

        //after user lends some token to the contract we send equivalent LendCoin token
        LendCoin.transfer(
            msg.sender,
            oracle.getDollarEquivalentOfThisToken(tokenAddress, amount)
        );
        //the problem is how much to send

        //here is what we need to do
        /**
        1. get the current price of one token in USD
        2. calculate the total amount in dollars for the amount of tokens.
         */

        //after lending we need to emit a supply event
        emit Supply(msg.sender, tokenAddress, amount);
    }

    function borrow(address tokenAddress, uint256 amount) external {
        //check for allowed token and amount not equal to zero
        require(
            isTokenAllowed(tokenAddress, tokensForBorrowing),
            "BORROW: Assest not supported"
        );
        require(amount > 0, "Cannot borrow zero amount");

        // uint256 totalBorrowableAmount = getTotalAmountForBorrowingForThisUser(msg.sender);
        // uint256 amountRequestedToBorrowInDollars = getDollarEquivalentOfThisToken(tokenAddress,amount);

        // require(amountRequestedToBorrowInDollars <= totalBorrowableAmount,"BORROW: Requested Amount is more than borrowable amount");

        IERC20 token = IERC20(tokenAddress);

        require(
            token.balanceOf(address(this)) >= amount,
            "BORROW: Insufficient Token Funds"
        );

        //if all good
        token.transfer(msg.sender, amount);

        //update user status in the platform
        (bool userPresent, int256 userIndex) = msg.sender.isUserPresentIn(
            borrowers
        );

        if (userPresent) {
            updateUserTokensBorrowedOrLent(
                tokenAddress,
                amount,
                userIndex,
                "borrowers"
            );
        } else {
            borrowers.push(msg.sender);
            tokensBorrowedAmount[tokenAddress][msg.sender] = amount;
            tokensBorrowed[noOfTokensBorrowed++][msg.sender] = tokenAddress;
        }

        //emit a borrow event
        emit Borrow(msg.sender, tokenAddress, amount);
    }

    // //withdraw
    // function withdraw(address tokenAddress, uint256 amount) external{
    //     require(amount > 0,"Cannot withdraw zero amount");
    //     require(msg.sender.indexOf(lenders) >= 0);

    //     IERC20 token = IERC20(tokenAddress);

    //     uint256 tokenWithdrawlAmount = getDollarEquivalentOfThisToken(tokenAddress,amount);

    //     //we need to deduct borrowedAmount from the collateralAmount
    //     uint256 availableTokenWithdrawlAmount = getAvailableTokenToWithdraw(msg.sender);

    // }

    function getAvailableTokenToWithdraw(
        address _user
    ) public view returns (uint256) {}

    function updateUserTokensBorrowedOrLent(
        address tokenAddress,
        uint256 amount,
        int256 userIndex,
        string memory lendersOrBorrowers
    ) private {
        if (
            keccak256(abi.encodePacked(lendersOrBorrowers)) ==
            keccak256(abi.encodePacked("lenders"))
        ) {
            address currentUser = lenders[uint256(userIndex)];

            if (
                hasLentOrBorrowedToken(
                    currentUser,
                    tokenAddress,
                    noOfTokensLent,
                    "tokensLent"
                )
            ) {
                tokensLentAmount[tokenAddress][currentUser] += amount;
            } else {
                tokensLent[noOfTokensLent++][currentUser] = tokenAddress;
                tokensLentAmount[tokenAddress][currentUser] = amount;
            }
        } else if (
            keccak256(abi.encodePacked(lendersOrBorrowers)) ==
            keccak256(abi.encodePacked("borrowers"))
        ) {
            address currentUser = borrowers[uint256(userIndex)];

            if (
                hasLentOrBorrowedToken(
                    currentUser,
                    tokenAddress,
                    noOfTokensBorrowed,
                    "tokensBorrowed"
                )
            ) {
                tokensBorrowedAmount[tokenAddress][currentUser] += amount;
            } else {
                tokensBorrowed[noOfTokensBorrowed++][
                    currentUser
                ] = tokenAddress;
                tokensBorrowedAmount[tokenAddress][currentUser] = amount;
            }
        }
    }

    function hasLentOrBorrowedToken(
        address currentUser,
        address tokenAddress,
        uint256 noOfTokenslentOrBorrowed,
        string memory _tokensLentOrBorrowed
    ) public view returns (bool) {
        if (noOfTokenslentOrBorrowed > 0) {
            if (
                keccak256(abi.encodePacked(_tokensLentOrBorrowed)) ==
                keccak256(abi.encodePacked("tokensLent"))
            ) {
                for (uint256 i = 0; i < noOfTokensLent; i++) {
                    address tokenAddressFound = tokensLent[i][currentUser];
                    if (tokenAddressFound == tokenAddress) {
                        return true;
                    }
                }
            } else if (
                keccak256(abi.encodePacked(_tokensLentOrBorrowed)) ==
                keccak256(abi.encodePacked("tokensBorrowed"))
            ) {
                for (uint256 i = 0; i < noOfTokensBorrowed; i++) {
                    address tokenAddressFound = tokensBorrowed[i][currentUser];
                    if (tokenAddressFound == tokenAddress) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function isTokenAllowed(
        address tokenAddress,
        Token[] memory tokenArray
    ) private pure returns (bool) {
        if (tokenArray.length > 0) {
            for (uint256 i = 0; i < tokenArray.length; i++) {
                if (tokenArray[i].tokenAddress == tokenAddress) {
                    return true;
                }
            }
        }
        return false;
    }

    function getUserTotalAmountAvailableForBorrowInDollars(
        address user
    ) public view returns (uint256) {
        // uint256 totalAvailableToBorrow = 0;

        uint256 userTotalCollateralToBorrow = 0;
        uint256 userTotalCollateralAlreadyBorrowed = 0;

        for (uint256 i = 0; i < lenders.length; i++) {
            address currentLender = lenders[i];
            if (currentLender == user) {
                for (uint256 j = 0; j < tokensForLending.length; j++) {
                    Token memory currentTokenForLending = tokensForLending[j];
                    uint256 currentTokenLentAmount = tokensLentAmount[
                        currentTokenForLending.tokenAddress
                    ][user];
                    uint256 currentTokenLentAmountInDollar = oracle.getDollarEquivalentOfThisToken(
                            currentTokenForLending.tokenAddress,
                            currentTokenLentAmount
                        );
                    uint256 availableInDollar = (currentTokenLentAmountInDollar *
                            currentTokenForLending.LTV) / 10 ** 18;
                    userTotalCollateralToBorrow += availableInDollar;
                }
            }
        }

        for (uint256 i = 0; i < borrowers.length; i++) {
            address currentBorrower = borrowers[i];
            if (currentBorrower == user) {
                for (uint256 j = 0; j < tokensForBorrowing.length; j++) {
                    Token memory currentTokenForBorrowing = tokensForBorrowing[
                        j
                    ];
                    uint256 currentTokenBorrowedAmount = tokensBorrowedAmount[
                        currentTokenForBorrowing.tokenAddress
                    ][user];
                    uint256 currentTokenBorrowedAmountInDollar = oracle.getDollarEquivalentOfThisToken(
                            currentTokenForBorrowing.tokenAddress,
                            currentTokenBorrowedAmount
                        );

                    userTotalCollateralAlreadyBorrowed += currentTokenBorrowedAmountInDollar;
                }
            }
        }

        return userTotalCollateralToBorrow - userTotalCollateralAlreadyBorrowed;
    }

    //ORACLE STUFF
    
    //EVENTS
    event Supply(address sender, address tokenAddress, uint256 amount);

    event Borrow(address sender, address tokenAddress, uint256 amount);
}
