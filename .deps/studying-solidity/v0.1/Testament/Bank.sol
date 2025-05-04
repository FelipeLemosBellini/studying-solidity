// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TestamentData.sol";

contract Bank is ReentrancyGuard {
    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    // Função de depósito
    function deposit() external payable {
        require(msg.value > 0, "Valor zero nao permitido");

        //_balances[msg.sender] += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    // Função de saque
    function withdraw(uint256 amount) external nonReentrant {
        /*require(_balances[msg.sender] >= amount, "Saldo insuficiente");

        _balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transferencia falhou");

        emit Withdrawn(msg.sender, amount);
        */
    }
}
