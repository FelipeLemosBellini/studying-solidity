// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

interface IProofOfLife {
    function updateProofOfLife(address testament) external;
}

interface ITestamentData {
    function getTestamentExist(address testator) external view returns (bool);
}

contract TestamentCore is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable
{
    address public contractInheritanceManagement;
    address public contractProofOfLife;

    function initialize() public initializer {
        __Ownable_init(msg.sender); //aqui eu defino o owner do contrato
        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __AccessControl_init();
    }

    function _authorizeUpgrade(address newAddress)
        internal
        override
        onlyOwner
    {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    //////////Modifiers//////////
    modifier onlyManager() {
        require(
            msg.sender == contractInheritanceManagement,
            "Only Manager can be called by Core"
        );
        _;
    }

    modifier onlyProofOfLife() {
        require(
            msg.sender == contractProofOfLife,
            "Only ProofOfLife can be called by Core"
        );
        _;
    }

    //////////Settings contracts//////////
    function setNewContractInheritanceManagement(
        address newContractInheritanceManagement
    ) external onlyOwner {
        contractInheritanceManagement = newContractInheritanceManagement;
    }

    function setNewContractProofOfLife(address newContractProofOfLife)
        external
        onlyOwner
    {
        contractProofOfLife = newContractProofOfLife;
    }

    ////////// Inheritance Management //////////
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
        address testator = msg.sender;

        bool _exist = !ITestamentData(contractInheritanceManagement)
            .getTestamentExist(testator);
        require(_exist, "Testamento ja existe. Use a funcao de edicao.");
    }

    function updateProofOfLife(address testament) external {
        require(testament != address(0), "Invalid address");
        bool _exist = !ITestamentData(contractInheritanceManagement)
            .getTestamentExist(testament);
        require(_exist, "Testamento ja existe. Use a funcao de edicao.");
        IProofOfLife(contractProofOfLife).updateProofOfLife(testament);
    }
}
