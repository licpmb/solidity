// SimpleDEX.sol
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.22;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleDEX is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event TokenSwapped(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
    tokenA = IERC20(_tokenA);
    tokenB = IERC20(_tokenB);
}

    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA > 0 && amountB > 0, "Amounts must be greater 0");

        // Transfer tokens to the contract
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        // Update reserves
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Input amount must be greater 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Calculate amount of B to transfer using constant product formula
        uint256 amountBOut = (amountAIn * reserveB) / (reserveA + amountAIn);

        require(amountBOut > 0, "Output amount too low");

        // Update reserves
        reserveA += amountAIn;
        reserveB -= amountBOut;

        // Transfer tokenA from the user and tokenB to the user
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        emit TokenSwapped(msg.sender, address(tokenA), address(tokenB), amountAIn, amountBOut);
    }

    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Input amount must be greater 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Calculate amount of A to transfer using constant product formula
        uint256 amountAOut = (amountBIn * reserveA) / (reserveB + amountBIn);

        require(amountAOut > 0, "Output amount too low");

        // Update reserves
        reserveB += amountBIn;
        reserveA -= amountAOut;

        // Transfer tokenB from the user and tokenA to the user
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        emit TokenSwapped(msg.sender, address(tokenB), address(tokenA), amountBIn, amountAOut);
    }

    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA <= reserveA && amountB <= reserveB, "Insufficient liquidity");

        // Update reserves
        reserveA -= amountA;
        reserveB -= amountB;

        // Transfer tokens back to the owner
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    function getPrice(address _token) external view returns (uint256) {
        require(_token == address(tokenA) || _token == address(tokenB), "Unsupported token");

        if (_token == address(tokenA)) {
            return reserveB * 1e18 / reserveA; // Price of 1 tokenA in terms of tokenB
        } else {
            return reserveA * 1e18 / reserveB; // Price of 1 tokenB in terms of tokenA
        }
    }
}