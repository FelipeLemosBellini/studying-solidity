// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./../structs/StructsToTestament.sol";

contract Testament is StructsToTestament {
    //dono do testamento: testamento
    mapping(address => Testament) public testament;

    // Cada herdeiro pode estar vinculado a múltiplos testamentos
    mapping(address => address[]) public inheritorToTestators;

    function createInheritance(
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
        address _ownOfTestament = msg.sender;

        require(
            !testament[_ownOfTestament].exist,
            "createInheritance(), voce ja tem um testamento criado, edite ele"
        );

        Testament storage _testament = testament[_ownOfTestament];

        //guarda cada herdeiro e porcentagem que vem do dApp
        for (uint256 i = 0; i < _addresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                _addresses[i],
                _percentagens[i],
                true
            );

            //adiciona o testador na lista de heranças do herdeiro
            inheritorToTestators[_addresses[i]].push(_ownOfTestament);

            //adiciona o herdeiro e % no testamento
            _testament.inheritors.push(_inheritor);
        }

        _testament.exist = true;
        _testament.inheritanceTotalValue = msg.value;
        updateProofOfLife();
    }

    function getMyTestament(address testator)
        external
        view
        returns (
            address[] memory,
            uint16[] memory,
            bool[] memory,
            uint128,
            uint256
        )
    {
        Testament memory _testator = testament[testator];

        require(_testator.exist, "Testador nao encontrado");

        address[] memory _inheritorAddresses = new address[](
            _testator.inheritors.length
        );

        uint16[] memory _percentages = new uint16[](
            _testator.inheritors.length
        );

        bool[] memory _canWithdrawal = new bool[](_testator.inheritors.length);

        for (uint64 i = 0; i < _testator.inheritors.length; i++) {
            Inheritor memory _currentInheritor = _testator.inheritors[i];

            _inheritorAddresses[i] = (_currentInheritor.inheritorAddress);
            _percentages[i] = (_currentInheritor.percentage);
            _canWithdrawal[i] = _currentInheritor.canWithdraw;
        }

        return (
            _inheritorAddresses,
            _percentages,
            _canWithdrawal,
            _testator.lastProofOfLife,
            _testator.inheritanceTotalValue
        );
    }

    function getMyTestators() external view returns (address[] memory) {
        address _inheritor = msg.sender;

        require(
            inheritorToTestators[_inheritor].length > 0,
            "Voce nao esta em nenhum testamento"
        );

        //retorna os endereços dos testadores que o herdeiro está no contrato
        return inheritorToTestators[_inheritor];
    }

    function editInheritorsInMyTestament(
        address[] calldata inheritorsAddresses,
        uint16[] calldata percentages
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

        delete testament[_ownTestament].inheritors;

        for (uint256 i = 0; i < inheritorsAddresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                inheritorsAddresses[i],
                percentages[i],
                true
            );

            //adiciona o herdeiro e % no testamento
            testament[_ownTestament].inheritors.push(_inheritor);

            //adiciona o testador na lista de heranças do herdeiro
            inheritorToTestators[inheritorsAddresses[i]].push(_ownTestament);
        }
    }

    function cancelTestament() external {
        address _ownTestament = msg.sender;

        require(testament[_ownTestament].exist, "voce nao possui testamento");
        (bool success, ) = msg.sender.call{
            value: testament[_ownTestament].inheritanceTotalValue
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

    function inheritorsCanWithdraw(address testator)
        public
        view
        returns (bool)
    {
        if (!testament[testator].exist) return false;

        uint256 ninetyDays = 1;
        //30 * 86400; // 30 dias em segundos

        return
            block.timestamp >= testament[testator].lastProofOfLife + ninetyDays;
    }

    function addAssetsInTestament() external payable {
        require(
            testament[msg.sender].exist,
            "voce nao possui testamento criado"
        );
        require(msg.value > 0, "insira um valor");
        testament[msg.sender].inheritanceTotalValue += msg.value;
    }

    function removeAssetsInTestament(uint256 value) external {
        require(
            testament[msg.sender].exist,
            "voce nao possui testamento criado"
        );
        require(
            value <= testament[msg.sender].inheritanceTotalValue,
            "voce nao tem isso tudo ai"
        );

        //atualiza o saldo primeiro e depois saca para evitar reentrancy attack
        testament[msg.sender].inheritanceTotalValue -= value;
        
        (bool success, ) = payable(msg.sender).call{value: value}("");

        require(success, "nao tirou");
    }

    function withdraw(address testator) external {
        address _inheritor = msg.sender;

        //verificar se tem ETH pra sacar
        require(
            inheritorsCanWithdraw(testator),
            "A retirada nao pode ser realizada"
        );

        require(testament[testator].inheritors.length > 0, "nao tem herdeiros");

        for (uint256 i = 0; i < testament[testator].inheritors.length; i++) {
            Inheritor storage inheritorOfTestament = testament[testator]
                .inheritors[i];

            if (
                inheritorOfTestament.inheritorAddress == _inheritor &&
                inheritorOfTestament.canWithdraw
            ) {
                require(
                    testament[testator].inheritanceTotalValue > 0,
                    "nao tem value no testamento"
                );

                //pega o valor que aquele herdeiro tem disponivel
                //porcentagem é com duas casas a mais e divide por 10000
                //exemplo (4000/10000) = 40%
                uint256 valueToWithdraw = (testament[testator]
                    .inheritanceTotalValue * inheritorOfTestament.percentage) /
                    10000;

                (bool success, ) = payable(
                    inheritorOfTestament.inheritorAddress
                ).call{value: (valueToWithdraw)}("");

                require(success, "Falha ao enviar ETH");

                inheritorOfTestament.canWithdraw = false;
                break;
            }
        }
        require(false, "voce nao esta no testamento");
    }
}
