// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/// @title SimpleDEX
/// @author Claudia Metz
/// @notice This contract implements a simple decentralized exchange using the constant product formula.
/// @dev Allows adding and removing liquidity, as well as swapping TokenA for TokenB and vice versa.


contract SimpleDEX {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;
    address public owner;


    /// @notice Contract constructor.
    /// @param _tokenA Address of the TokenA contract.
    /// @param _tokenB Address of the TokenB contract.
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }


    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);    //when owner adds liquidity.
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);  //when owner takes liquidity.
    event SwapAforB(address indexed swapper, uint256 amountAIn, uint256 amountBOut);     // swap ETA -> ETB 
    event SwapBforA(address indexed swapper, uint256 amountBIn, uint256 amountAOut);     // swap ETB -> ETA


    /// @notice Adds liquidity to the pool.
    /// @param amountA: Amount of TokenA to add.
    /// @param amountB: Amount of TokenB to add.
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        reserveA += amountA;
        reserveB += amountB;
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice Swaps TokenA for TokenB.
    /// @param amountAIn Amount of TokenA to swap.
    function swapAforB(uint256 amountAIn) external {
        uint256 amountBOut = getAmountOut(amountAIn, reserveA, reserveB);
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);
        reserveA += amountAIn;
        reserveB -= amountBOut;
        emit SwapAforB(msg.sender, amountAIn, amountBOut);
    }

    /// @notice Swaps TokenB for TokenA.
    /// @param amountBIn Amount of TokenB to swap.
    function swapBforA(uint256 amountBIn) external {
        uint256 amountAOut = getAmountOut(amountBIn, reserveB, reserveA);
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);
        reserveB += amountBIn;
        reserveA -= amountAOut;
        emit SwapBforA(msg.sender, amountBIn, amountAOut);
    }

    /// @notice Removes liquidity from the pool.
    /// @param amountA Amount of TokenA to remove.
    /// @param amountB Amount of TokenB to remove.
    function removeLiquidity(uint256 amountA, uint256 amountB) external {
        require(reserveA >= amountA && reserveB >= amountB, "Insufficient liquidity");
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);
        reserveA -= amountA;
        reserveB -= amountB;
        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Gets the price of one token in terms of the other.
    /// @param _token Address of the token to get the price for.
    /// @return The price of the token in terms of the other token.
    function getPrice(address _token) external view returns (uint256) {
        if (_token == address(tokenA)) {
            return reserveB / reserveA;
        } else if (_token == address(tokenB)) {
            return reserveA / reserveB;
        } else {
            revert("Invalid token address");
        }
    }

    /// @notice Calculates the output amount using the constant product formula.
    /// @param amountIn Amount of input tokens.
    /// @param reserveIn Reserve of input tokens.
    /// @param reserveOut Reserve of output tokens.
    /// @return The amount of output tokens.
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        uint256 newReserveIn = reserveIn + amountIn;
        uint256 newReserveOut = reserveOut * reserveIn / newReserveIn;
        return reserveOut - newReserveOut;
    }
}