//
pragma solidity >=0.8.0 <0.9.0;

contract ExampleAddress {
    address private someAddress;

    function setAddress(address _addr) public {
        someAddress = _addr;
    }

    function getAddress() public view returns (address) {
        return someAddress;
    }

    function getBalance() public view returns(uint) {
        return someAddress.balance;
    }
}
