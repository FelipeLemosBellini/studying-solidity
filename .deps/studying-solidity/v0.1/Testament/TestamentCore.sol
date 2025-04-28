// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./TestamentStorage.sol";
import "./ProofOfLife.sol";
import "./BaseModifiers.sol";

contract TestamentCore is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    TestamentStorage,
    ProofOfLife
{
    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __AccessControl_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

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
            !testaments[_ownOfTestament].exist,
            "createInheritance(), voce ja tem um testamento criado, edite ele"
        );

        Testament storage _testament = testaments[_ownOfTestament];

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

    function editInheritorsInMyTestament() external {
        // Editar herdeiros
    }

    function cancelTestament() external {
        // Cancelar testamento
    }
}
