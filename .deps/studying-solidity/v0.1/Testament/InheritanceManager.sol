// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./TestamentData.sol";

interface ITestamentData {
    function createInheritance(
        address ownerTestament,
        uint256 amount,
        address[] calldata _addresses,
        uint16[] calldata _percentagens
    ) external;
}

contract InheritanceManager is Ownable {
    address public testamentData;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function createInheritance(
        uint256 amount,
        address[] calldata _addresses,
        uint16[] calldata _percentagens
    ) external payable {
        //checagens para continuar o contrato
        require(msg.value != 0, "createInheritance(), valor invalido");
        require(
            _addresses.length != 0,
            "createInheritance(), adicione os herdeiros"
        );
        require(
            _addresses.length == _percentagens.length,
            "createInheritance(), quantidade de enderecos e porcentagens diferentes"
        );
        address testator = msg.sender;

        ITestamentData(testamentData).createInheritance(
            testator,
            amount,
            _addresses,
            _percentagens
        );
    }
}
