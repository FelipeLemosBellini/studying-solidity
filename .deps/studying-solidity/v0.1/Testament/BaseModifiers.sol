// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TestamentStorage.sol";

contract BaseModifiers is TestamentStorage {
    // Modificador compartilhado
    modifier onlyTestator() {
        require(testaments[msg.sender].exist, "Voce nao eh um testador!");
        _;
    }

    //modifier onlyHerdeiro() {}
}