// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./TestamentData.sol";

interface ITestamentData {
    function setProofOfLife(address user, uint128 timestamp) external;
}

contract ProofOfLife is Ownable {
    address public contractCore;
    address public contractData;

    constructor(address initialOwner) Ownable(initialOwner) {}

    modifier onlyCore() {
        require(
            msg.sender == contractCore,
            "Only TestamentCore can call this function"
        );
        _;
    }

    function setNewOwner(address newOwner) external onlyOwner {
        transferOwnership(newOwner);
    }

    function setCore(address core) external onlyOwner {
        require(core != address(0), "Invalid Core address");
        contractCore = core;
    }

    function setData(address data) external onlyOwner {
        require(data != address(0), "Invalid Data address");
        contractData = data;
    }

    function updateProofOfLife(address testament) external onlyCore {
        uint128 timestampNow = uint128(block.timestamp);
        ITestamentData(contractData).setProofOfLife(testament, timestampNow);
    }
}
