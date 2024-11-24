// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenA is ERC20, Ownable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("TokenA", "TKA")
        Ownable(initialOwner)
        ERC20Permit("TokenA")
    {
        _mint(msg.sender, 5000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}



/*SimpleDex Ejemplo 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @author [Salvador Piccolini]
contract SimpleDEX is Ownable {
    /// Token A 
    IERC20 public tokenA;

    /// Token B 
    IERC20 public tokenB;

    ///  The amount of token A added
    ///  The amount of token B added
    event LiquidityAdded(uint256 amountA, uint256 amountB);

    /// Emitted when liquidity is removed
    event LiquidityRemoved(uint256 amountA, uint256 amountB);

    /// The address of the user performing the swap
    event TokenSwapped(address indexed user, uint256 amountIn, uint256 amountOut);

    /// Initializes the DEX with two tokens
    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        
    }

    /// Adds liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        emit LiquidityAdded(amountA, amountB);
    }

    /// Removes liquidity from the pool
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA <= tokenA.balanceOf(address(this)) && amountB <= tokenB.balanceOf(address(this)), "Low liquidity");

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(amountA, amountB);
    }

    /// Swaps token A for token B
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be > 0");

        uint256 amountBOut = getAmountOut(amountAIn, tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this)));

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        emit TokenSwapped(msg.sender, amountAIn, amountBOut);
    }

    /// Swaps token B for token A
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be > 0");

        uint256 amountAOut = getAmountOut(amountBIn, tokenB.balanceOf(address(this)), tokenA.balanceOf(address(this)));

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        emit TokenSwapped(msg.sender, amountBIn, amountAOut);
    }

    /// Gets the price of a token relative to the other
    function getPrice(address _token) external view returns (uint256) {
        require(_token == address(tokenA) || _token == address(tokenB), "Invalid token");

        return _token == address(tokenA)
            ? (tokenB.balanceOf(address(this)) * 1e18) / tokenA.balanceOf(address(this))
            : (tokenA.balanceOf(address(this)) * 1e18) / tokenB.balanceOf(address(this));
    }

    /// Calculates the output amount of a swap
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256) {
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }
}

*/

/*SimpleDEX Ejemplo 2

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

*/