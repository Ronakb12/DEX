# Decentralized Exchange (DEX) Assignment

## Testnet

Sepolia

---

## Deployed Contracts

TokenA: 0x075F4bA80abc9FE84E875887e2b85aCD187E2943
TokenB: 0xA9aa571EE8d0F6FCD6f9a96C7E598F90c99D63E1

DEX1: 0xBe58Fc9A9CD5282E7A0Db046112BbAb208E0B852
LPToken1: 0x5dC2683a61558d24E610b6f0f0f0653c60468Aa6

DEX2: 0xc0BcfF6227Bd14b61fFb08C2Ddaa139a2d89a817
LPToken2: 0xfca04F49326EB3E72EB2E3F513924ed7CC531cCd

Arbitrage: 0xD25b7fA3ce89F9E7454EA12Fd3B77942d12F9777

---

## Transactions

Add Liquidity: 0x5c4ba494c91ec06674134129d87a2a7cfed0aa1533ea3b9ba5edfbb6c0faadfd
Swap A → B: 0x71906095f135cf19485e3315a0d5eb7cff691a7e79ee15a4f5f7561b85254025
Swap B → A: 0x58bd6c19f5b9cc6b5b1b3ea9332585ee5f5156c1e569dcad04181bcafe8c1b69
Remove Liquidity: 0x2d1f464be872bed88786e2fe01a4a1af8cc2f61df49691a474b297b62b17efb4
Arbitrage (Profitable): 0x9d4537ec07b5ea0da3d6b462efa37c39456ec7545f70b7d8a9636f6d543807b0
Arbitrage (Failed): 0xa7f451fd1804b5e6e1e8c669ce22d91e78154a105ebf067611e231540122334e

---
## Video URL Youtube

https://youtu.be/L7kk-_dK9hI


## How to Use

1. Connect MetaMask to Sepolia
2. Approve TokenA and TokenB to DEX
3. Add liquidity using addLiquidity()
4. Perform swaps using swapAforB() and swapBforA()
5. Run arbitrage using executeArbitrage()

---

## Overview

This project implements a constant product Automated Market Maker (AMM) using the formula x * y = k.

Liquidity providers deposit TokenA and TokenB in a fixed ratio and receive LP tokens representing their share.

Swaps are executed with a 0.3% fee, and prices are determined dynamically based on pool reserves.

The arbitrage contract detects price differences between two DEX instances, simulates trades, and executes only when profitable.
