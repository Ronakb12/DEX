// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract LPToken is ERC20, Ownable {
    address public dex;

    constructor()
        ERC20("LP Token", "LPT")
        Ownable(msg.sender)
    {}

    function setDEX(address _dex) external onlyOwner {
        dex = _dex;
    }

    modifier onlyDEX() {
        require(msg.sender == dex, "Not DEX");
        _;
    }

    function mint(address to, uint amount) external onlyDEX {
        _mint(to, amount);
    }

    function burn(address from, uint amount) external onlyDEX {
        _burn(from, amount);
    }
}