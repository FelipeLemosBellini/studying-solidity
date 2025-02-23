// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./../structs/StructsToTestament.sol";

contract Testament is StructsToTestament {
    //dono do testamento: testamento
    mapping(address => Testament) public testament;

    // Cada herdeiro pode estar vinculado a múltiplos testamentos
    mapping(address => address[]) public inheritorToTestators;

    function createInheritance(
        address[] memory _addresses,
        uint8[] memory _percentagens
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
        address _ownOfTestament = msg.sender;

        require(
            !testament[_ownOfTestament].exist,
            "createInheritance(), voce ja tem um testamento criado, edite ele"
        );

        //guarda cada herdeiro e porcentagem que vem do dApp
        for (uint256 i = 0; i < _addresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                _addresses[i],
                _percentagens[i]
            );

            //adiciona o testador na lista de heranças do herdeiro
            inheritorToTestators[_addresses[i]].push(_ownOfTestament);

            //adiciona o herdeiro e % no testamento
            testament[_ownOfTestament].inheritors.push(_inheritor);
        }

        testament[_ownOfTestament].exist = true;
        testament[_ownOfTestament].balance = msg.value;
        updateProofOfLife();
    }

    function getMyTestament(address testator)
        external
        view
        returns (
            address[] memory,
            uint64[] memory,
            uint128,
            uint256
        )
    {
        Testament memory _testator = testament[testator];

        require(_testator.exist, "Testador nao encontrado");

        address[] memory _inheritorAddresses = new address[](
            _testator.inheritors.length
        );

        uint64[] memory _percentages = new uint64[](
            _testator.inheritors.length
        );

        for (uint64 i = 0; i < _testator.inheritors.length; i++) {
            Inheritor memory _currentInheritor = _testator.inheritors[i];

            _inheritorAddresses[i] = (_currentInheritor.inheritorAddress);
            _percentages[i] = (_currentInheritor.percentage);
        }

        return (
            _inheritorAddresses,
            _percentages,
            _testator.lastProofOfLife,
            _testator.balance
        );
    }

    function getMyTestators() external view returns (address[] memory) {
        address _inheritor = msg.sender;

        //retorna os endereços dos testadores que o herdeiro está no contrato
        return inheritorToTestators[_inheritor];
    }

    function editInheritorsInMyTestament(
        address[] calldata inheritorsAddresses,
        uint64[] calldata percentages
    ) external {
        address _ownTestament = msg.sender;
        require(
            inheritorsAddresses.length != 0,
            "createInheritance(), adicione os herdeiros"
        );
        require(
            inheritorsAddresses.length == percentages.length,
            "createInheritance(), quantidade de enderecos e porcentagens diferentes"
        );

        clearOldInheritorsOfTestament(_ownTestament);

        //Adicionar os novos herdeiros
        //guarda cada herdeiro e porcentagem que vem do dApp
        for (uint256 i = 0; i < inheritorsAddresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                inheritorsAddresses[i],
                percentages[i]
            );

            //adiciona o herdeiro e % no testamento
            testament[_ownTestament].inheritors.push(_inheritor);

            //adiciona o testador na lista de heranças do herdeiro
            inheritorToTestators[inheritorsAddresses[i]].push(_ownTestament);
        }
    }

    function cancelTestament() external {
        address _ownTestament = msg.sender;

        (bool success, ) = msg.sender.call{
            value: testament[_ownTestament].balance
        }("");
        require(success, "cancelTestament(), Falha ao enviar ETH");

        clearOldInheritorsOfTestament(_ownTestament);

        delete testament[_ownTestament];
    }

    function updateProofOfLife() public {
        address own = msg.sender;
        require(
            testament[own].exist,
            "Voce nao possui nenhum testamento criado"
        );
        testament[own].lastProofOfLife = uint128(block.timestamp);
    }

    function clearOldInheritorsOfTestament(address _ownTestament) internal {
        //Apagar herdeiros anteriores
        //herdeiros anteriores
        Inheritor[] memory oldInheritors = testament[_ownTestament].inheritors;

        //corre a lista de herdeiros antigos
        for (uint256 i = 0; i < oldInheritors.length; i++) {
            //pega a lista de testadores que o herdeiro está no testamento
            address[] memory testatorsOfOldInheritor = inheritorToTestators[
                oldInheritors[i].inheritorAddress
            ];

            uint256 length = testatorsOfOldInheritor.length;

            // Percorre a lista de testadores e remove o que for igual a do testador do testamento que está sendo editado
            for (uint256 j = 0; j < length; j++) {
                if (testatorsOfOldInheritor[j] == _ownTestament) {
                    testatorsOfOldInheritor[j] = testatorsOfOldInheritor[
                        length - 1
                    ]; // Substitui pelo último
                    inheritorToTestators[oldInheritors[i].inheritorAddress]
                        .pop(); // Remove o último
                    break; // Sai do loop após remover um match
                }
            }
        }
    }
}
