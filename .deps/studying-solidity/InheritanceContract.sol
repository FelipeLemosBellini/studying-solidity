// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InheritanceContract {
    struct Inheritor {
        address inheritorAddress;
        uint8 percentage;
    }

    struct Testator {
        Inheritor[] inheritors;
        bool exist;
        uint256 lastProofOfLife;
        //salvar as moedas aqui
    }

    mapping(address => Testator) public testators;

    function createInheritance(
        address[] memory _addresses,
        uint8[] memory _percentagens
    ) external {
        address own = msg.sender;

        if (testators[own].exist) delete testators[own].inheritors;

        for (uint256 i = 0; i < _addresses.length; i++) {
            Inheritor memory _inheritor = Inheritor(
                _addresses[i],
                _percentagens[i]
            );

            testators[own].inheritors.push(_inheritor);
        }
        testators[own].exist = true;
        testators[own].lastProofOfLife = block.timestamp;
    }

    function getMyTestament()
        external
        view
        returns (address[] memory, uint8[] memory)
    {
        address own = msg.sender;
        require(testators[own].exist, "Testador nao encontrado");

        address[] memory _inheritorAddresses = new address[](
            testators[own].inheritors.length
        );

        uint8[] memory _percentages = new uint8[](
            testators[own].inheritors.length
        );

        for (uint256 i = 0; i < testators[own].inheritors.length; i++) {
            Inheritor memory _currentInheritor = testators[own].inheritors[i];

            _inheritorAddresses[i] = (_currentInheritor.inheritorAddress);
            _percentages[i] = (_currentInheritor.percentage);
        }

        return (_inheritorAddresses, _percentages);
    }

    function checkIfTestatorExist() private view returns (bool) {
        return testators[msg.sender].exist;
    }

    function cancelTestament() public {
        address own = msg.sender;

        delete testators[own];
    }

    function updateProofOfLife() external {
        address own = msg.sender;
        require(testators[own].exist, "Testador nao existe");
        testators[own].lastProofOfLife = block.timestamp;
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
