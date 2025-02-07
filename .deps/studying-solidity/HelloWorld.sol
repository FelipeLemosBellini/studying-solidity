// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.8< 0.9.0;

contract HelloWorld {
    string public message = "Hello World";


    function setMessage(string memory _newMessage) public {
        message = _newMessage;
    }

    function compareCurrentString(string memory _textToCompare) public view  returns (bool) {
        return keccak256(abi.encodePacked(message)) == keccak256(abi.encodePacked(_textToCompare));
    }
}
