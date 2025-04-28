// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestamentStorage {
    struct Inheritor {
        address inheritorAddress;
        uint16 percentage;
        bool canWithdraw;
    }

    struct Testament {
        Inheritor[] inheritors;
        bool exist;
        uint128 lastProofOfLife;
        uint256 inheritanceTotalValue;
        //salvar as moedas aqui
    }

    //dono do testamento: testamento
    mapping(address => Testament) public testaments;

    // Cada herdeiro pode estar vinculado a múltiplos testamentos
    mapping(address => address[]) public inheritorToTestators;
}