// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestamentProxy is ERC1967Proxy {
    address public implementation;  // endereço da lógica (TestamentCore)
    address public admin;           // dono que pode mudar a implementação

    constructor(address _logic, bytes memory _data)
        ERC1967Proxy(_logic, _data)
    {}

    function updateImplementation(address _newImplementation) external {
        require(msg.sender == admin, "Somente admin pode mudar");
        implementation = _newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation nao setada");

        assembly {
            // Copy call data
            calldatacopy(0, 0, calldatasize())

            // Delegate call para o impl
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // Copy retorno
            returndatacopy(0, 0, returndatasize())

            //switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}