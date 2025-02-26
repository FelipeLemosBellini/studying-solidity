// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructsToTestament {
    struct Inheritor {
        address inheritorAddress;
        uint16 percentage;
        bool canWithdraw;
    }

    struct Testament {
        Inheritor[] inheritors;
        bool exist;
        uint128 lastProofOfLife;
        uint256 inheritanceValue;
        //salvar as moedas aqui
    }
}
