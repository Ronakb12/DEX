// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DEX.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Arbitrage {
    address public owner;

    event ArbitrageExecuted(
        address dexBuy,
        address dexSell,
        uint amountIn,
        uint profit
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function executeArbitrage(
        address dex1,
        address dex2,
        address tokenA,
        address tokenB,
        uint amountIn,
        uint minProfit
    ) external onlyOwner {

        // Check contract has funds
        require(IERC20(tokenA).balanceOf(address(this)) >= amountIn, "Insufficient capital");

        // Get prices
        uint price1 = DEX(dex1).getPriceAinB();
        uint price2 = DEX(dex2).getPriceAinB();

        require(price1 != price2, "No arbitrage");

        if (price1 > price2) {
            // B cheaper in dex1
            _arb(dex1, dex2, tokenA, tokenB, amountIn, minProfit);
        } else {
            _arb(dex2, dex1, tokenA, tokenB, amountIn, minProfit);
        }
    }

    // simulation with 0.3% fee
    function getAmountSim(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure returns (uint) {
        uint amountInWithFee = (amountIn * 997) / 1000;
        return (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);
    }

    //Simulate
    function simulate(
    address dexBuy,
    address dexSell,
    uint amountIn
    ) internal view returns (uint aOut) {
        // Get reserves
        (uint rA1, uint rB1) = DEX(dexBuy).getReserves();
        (uint rA2, uint rB2) = DEX(dexSell).getReserves();

        // Simulate trades
        uint bOut = getAmountSim(amountIn, rA1, rB1);
        aOut = getAmountSim(bOut, rB2, rA2);

    }

    function _arb(
        address dexBuy,
        address dexSell,
        address tokenA,
        address tokenB,
        uint amountIn,
        uint minProfit
    ) internal {

        // Run Simulation
        uint aOut = simulate(dexBuy, dexSell, amountIn);

        // Stop if not profitable
        require(aOut > amountIn + minProfit, "Not profitable");

        uint initialA = IERC20(tokenA).balanceOf(address(this));
        uint bBefore = IERC20(tokenB).balanceOf(address(this));

        // Swap A -> B
        IERC20(tokenA).approve(dexBuy, amountIn);
        DEX(dexBuy).swapAforB(amountIn);

        uint bBalance = IERC20(tokenB).balanceOf(address(this)) - bBefore;

        // Swap B -> A
        IERC20(tokenB).approve(dexSell, bBalance);
        DEX(dexSell).swapBforA(bBalance);

        uint finalA = IERC20(tokenA).balanceOf(address(this));

        uint profit = finalA - initialA;
        require(profit >= minProfit, "Profit too low");

        emit ArbitrageExecuted(dexBuy, dexSell, amountIn, profit);
    }

    // Withdraw funds
    function withdraw(address token) external onlyOwner {
        uint bal = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, bal);
    }
}