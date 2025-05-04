// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

//Structs
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

contract TestamentData is Ownable {
    address public proofOfLife;

    //Mappings com os dados
    //dono do testamento: testamento
    mapping(address => Testament) private testaments;

    // Cada herdeiro pode estar vinculado a múltiplos testamentos
    mapping(address => address[]) private inheritorToTestators;

    constructor(address initialOwner) Ownable(initialOwner) {}

    modifier onlyTestator() {
        require(testaments[msg.sender].exist, "Voce nao eh testador");
        _;
    }

    modifier onlyProofOfLife() {
        require(msg.sender == proofOfLife, "Unauthorized");
        _;
    }

    function setProofOfLife(address _proofOfLife) external onlyOwner {
        require(_proofOfLife != address(0), "Invalid Core address");
        proofOfLife = _proofOfLife;
    }

    // Setters
    function createInheritance(
        address ownerTestament,
        uint256 amount,
        address[] calldata _addresses,
        uint16[] calldata _percentagens
    ) external {
        Testament storage _testament = testaments[ownerTestament];

        //guarda cada herdeiro e porcentagem que vem do dApp
        for (uint256 i = 0; i < _addresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                _addresses[i],
                _percentagens[i],
                true
            );

            //adiciona o testador na lista de heranças do herdeiro
            inheritorToTestators[_addresses[i]].push(ownerTestament);

            //adiciona o herdeiro e % no testamento
            _testament.inheritors.push(_inheritor);
        }

        _testament.exist = true;
        _testament.inheritanceTotalValue = amount;
    }

    function setProofOfLife(address user, uint128 timestamp) external {
        testaments[user].lastProofOfLife = timestamp;
    }

    //Getters
    function getIfTestamentExist(address testator)
        external
        view
        returns (bool)
    {
        return testaments[testator].exist;
    }

    function getTestamentOf(address testator)
        external
        view
        onlyTestator
        returns (Testament memory)
    {
        require(testaments[testator].exist, "Testament not found");
        return testaments[testator];
    }
}
