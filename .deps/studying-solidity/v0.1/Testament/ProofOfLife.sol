// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TestamentStorage.sol";

contract ProofOfLife is TestamentStorage {

    function updateProofOfLife() internal {
        address own = msg.sender;
        require(
            testaments[own].exist,
            "Voce nao possui nenhum testamento criado"
        );
        testaments[own].lastProofOfLife = uint128(block.timestamp);
    }
}