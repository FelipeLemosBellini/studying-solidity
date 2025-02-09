// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositAndWithdrawal {
    Herdeiro public _onlyReceiver;
    //lista das moedas de herança

    struct Herdeiro {
        address receptor;
        uint256 percentage;
    }

    event DepositEvent(address sender, uint256 amount);

    event WithdrawEvent(address receptor, uint256 amount);

    function deposit(address onlyReceiver, uint256 percentage)
        external
        payable
    {
        require(msg.value > 0, "Precisa enviar ETH");
        emit DepositEvent(msg.sender, msg.value);
        _onlyReceiver = Herdeiro(onlyReceiver, percentage);
    }

    function withdraw() external {
        require(msg.sender == _onlyReceiver.receptor, "voce nao pode sacar");
        uint256 balance = address(this).balance;
        require(balance > 0, "Contrato sem saldo");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Erro ao mandar o ETH");
        emit WithdrawEvent(_onlyReceiver.receptor, balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}


