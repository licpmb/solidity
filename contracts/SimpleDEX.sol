// SimpleDEX.sol
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleDEX is Ownable {
    address public tokenA;
    address public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    constructor(address _tokenA, address _tokenB) Ownable (msg.sender) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(uint256 amountA, uint256 amountB) public {
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "Transfer of Token A failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "Transfer of Token B failed");

        reserveA += amountA;
        reserveB += amountB;
    }

    function swapAforB(uint256 amountAIn) public {
        uint256 amountBOut = (amountAIn * reserveB) / (reserveA + amountAIn);
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountAIn), "Transfer of Token A failed");
        require(IERC20(tokenB).transfer(msg.sender, amountBOut), "Transfer of Token B failed");

        reserveA += amountAIn;
        reserveB -= amountBOut;
    }

    function swapBforA(uint256 amountBIn) public {
        uint256 amountAOut = (amountBIn * reserveA) / (reserveB + amountBIn);
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountBIn), "Transfer of Token B failed");
        require(IERC20(tokenA).transfer(msg.sender, amountAOut), "Transfer of Token A failed");

        reserveA -= amountAOut;
        reserveB += amountBIn;
    }

    function removeLiquidity(uint256 amountA, uint256 amountB) public {
        require(reserveA >= amountA && reserveB >= amountB, "Not enough liquidity");

        require(IERC20(tokenA).transfer(msg.sender, amountA), "Transfer of Token A failed");
        require(IERC20(tokenB).transfer(msg.sender, amountB), "Transfer of Token B failed");

        reserveA -= amountA;
        reserveB -= amountB;
    }

    function getPrice(address _token) public view returns (uint256) {
        if (_token == tokenA) {
            return reserveB / reserveA;
        } else {
            return reserveA / reserveB;
        }
    }
}