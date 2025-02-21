// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// openzeppelin ela tem outros utils que podemos usar
// ela tem um negocio de segurança para rodar a função de saque **********

import "@openzeppelin/contracts/utils/Strings.sol";

interface IInheritanceContract {
    function createInheritance(
        address[] memory _addresses,
        uint8[] memory _percentagens
    ) external payable;

    function getMyTestament()
        external
        view
        returns (
            address[] memory,
            uint64[] memory,
            uint128,
            uint256
        );

    function updateProofOfLife() external;

    function withdrawal() external;
}

contract InheritanceContract is IInheritanceContract {
    using Strings for uint256;
    struct Inheritor {
        address inheritorAddress;
        uint64 percentage;
    }

    struct Testator {
        Inheritor[] inheritors;
        bool exist;
        uint128 lastProofOfLife;
        uint256 totalAmount;
        //salvar as moedas aqui
    }

    mapping(address => Testator) public testators;

    mapping(address => address) public inheritorToTestator;

    //implementado
    function createInheritance(
        address[] memory _addresses,
        uint8[] memory _percentagens
    ) external payable {
        require(msg.value != 0, "createInheritance(), valor invalido");
        require(
            _addresses.length != 0,
            "createInheritance(), adicione os herdeiros"
        );
        require(
            _addresses.length == _percentagens.length,
            "createInheritance(), quantidade de enderecos e porcentagens diferentes"
        );

        address own = msg.sender;

        if (testators[own].exist) delete testators[own].inheritors;

        for (uint256 i = 0; i < _addresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                _addresses[i],
                _percentagens[i]
            );

            inheritorToTestator[_addresses[i]] = own;
            testators[own].inheritors.push(_inheritor);
        }
        testators[own].exist = true;
        testators[own].lastProofOfLife = uint128(block.timestamp);
        testators[own].totalAmount = msg.value;
    }

    //implementado
    function getMyTestament()
        external
        view
        returns (
            address[] memory,
            uint64[] memory,
            uint128, //timestamp last proof of life
            uint256 //amount
        )
    {
        address own = msg.sender;

        Testator memory _testator = testators[own];

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
            _testator.totalAmount
        );
    }

    //implementado
    function updateProofOfLife() external {
        address own = msg.sender;
        require(testators[own].exist, "Testador nao existe");
        testators[own].lastProofOfLife = uint128(block.timestamp);
    }

    function checkIfTestatorExist() private view returns (bool) {
        return testators[msg.sender].exist;
    }

    function cancelTestament() external {
        address own = msg.sender;

        (bool success, ) = msg.sender.call{value: testators[own].totalAmount}(
            ""
        );
        require(success, "cancelTestament(), Falha ao enviar ETH");

        delete testators[own];
    }

    function withdrawal() external {
        address _inheritor = msg.sender;
        address ownInheritance = inheritorToTestator[_inheritor];
        require(
            ownInheritance != address(0),
            "voce nao foi cadastrado em nenhum testamento"
        );

        require(testators[ownInheritance].exist, "testamento nao encontrado");

        Testator memory _testator = testators[ownInheritance];

        for (uint256 i = 0; _testator.inheritors.length >= i; i++) {
            if (_inheritor == _testator.inheritors[i].inheritorAddress) {
                uint256 _amount = _testator.inheritors[i].percentage *
                    _testator.totalAmount;

                //vc criou um amount sacado na struct de Testator, vc precisa saber se
                //já teve algum saque de herdeiro pra não sacar 40% depois 60% do que sobrou,
                //vc pode guardar os valores que devem ser enviados

                payable(msg.sender).transfer(_amount);
            }
        }
    }
}

/*{
    "0xsadas": {
        "inheritors":{
            "0xdasdaas":{"percentage":50},
            "0xiuyukhj":{"percentage":50},
        },
    },
    "0xuykjh": {
        "inheritors":{
            "0xdasdaas":{"percentage":50},
            "0xiuyukhj":{"percentage":50},
        },

    },
}

 /*function depositETH() external payable {}

    function withdrawETH() external {}

    */
