// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LPToken.sol";

contract DEX {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    LPToken public immutable lpToken;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 private constant FEE_NUMERATOR = 997;
    uint256 private constant FEE_DENOMINATOR = 1000;

    event LiquidityAdded(address indexed user, uint amountA, uint amountB);
    event LiquidityRemoved(address indexed user, uint amountA, uint amountB);
    event Swap(address indexed user, address tokenIn, uint amountIn, uint amountOut);

    constructor(address _tokenA, address _tokenB, address _lpToken) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        lpToken = LPToken(_lpToken);
    }

    // To Add Liquidity
    function addLiquidity(uint amountA, uint amountB) external {
        require(amountA > 0 && amountB > 0, "Invalid Amounts - addLiquidity ");

        if (reserveA > 0 || reserveB > 0) {
            uint expectedB = (amountA * reserveB) / reserveA;
            require(amountB == expectedB, "Invalid Ratio - addLiquidity");
        }

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint lpAmount;

        if (lpToken.totalSupply() == 0) {
            lpAmount = sqrt(amountA * amountB); // initial liquidity
        } else {
            uint totalSupply = lpToken.totalSupply();
            uint lpA = (amountA * totalSupply) / reserveA;
            uint lpB = (amountB * totalSupply) / reserveB;
            lpAmount = lpA < lpB ? lpA : lpB;
        }

        lpToken.mint(msg.sender, lpAmount);

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    // To Remove Liquidity
    function removeLiquidity(uint lpAmount) external {
        require(lpAmount > 0, "Invalid amount - removeLiquidity");

        uint totalSupply = lpToken.totalSupply();

        uint amountA = (lpAmount * reserveA) / totalSupply;
        uint amountB = (lpAmount * reserveB) / totalSupply;

        lpToken.burn(msg.sender, lpAmount);

        reserveA -= amountA;
        reserveB -= amountB;

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    // To Swap A → B
    function swapAforB(uint amountAIn) external returns (uint amountBOut) {
        require(amountAIn > 0, "Invalid input");

        uint amountInWithFee = (amountAIn * FEE_NUMERATOR) / FEE_DENOMINATOR;

        amountBOut = (reserveB * amountInWithFee) /
                     (reserveA + amountInWithFee);

        require(amountBOut > 0 && amountBOut < reserveB, "Insufficient liquidity");

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit Swap(msg.sender, address(tokenA), amountAIn, amountBOut);
    }

    // To Swap B → A
    function swapBforA(uint amountBIn) external returns (uint amountAOut) {
        require(amountBIn > 0, "Invalid input");

        uint amountInWithFee = (amountBIn * FEE_NUMERATOR) / FEE_DENOMINATOR;

        amountAOut = (reserveA * amountInWithFee) /
                     (reserveB + amountInWithFee);

        require(amountAOut > 0 && amountAOut < reserveA, "Insufficient liquidity");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit Swap(msg.sender, address(tokenB), amountBIn, amountAOut);
    }

    function sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
    }

    // Spot Price
    function getPriceAinB() public view returns (uint) {
        require(reserveA > 0, "No liquidity");
        return (reserveB * 1e18) / reserveA;
    }

    function getPriceBinA() public view returns (uint) {
        require(reserveB > 0, "No liquidity");
        return (reserveA * 1e18) / reserveB;
    }

    function getReserves() external view returns (uint, uint) {
        return (reserveA, reserveB);
    }
}