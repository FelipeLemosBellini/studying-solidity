// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositAndWithdrawal {
    address public _onlyReceiver;

    event DepositEvent(address sender, uint256 amount);

    event WithdrawEvent(address receptor, uint256 amount);

    function deposit(address onlyReceiver) external payable {
        require(msg.value > 0, "Precisa enviar ETH");
        emit DepositEvent(msg.sender, msg.value);
        _onlyReceiver = onlyReceiver;
    }

    function withdraw() external {
        require(msg.sender == _onlyReceiver, "voce nao pode sacar");
        uint256 balance = address(this).balance;
        require(balance > 0, "Contrato sem saldo");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Erro ao mandar o ETH");
        emit WithdrawEvent(_onlyReceiver, balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
