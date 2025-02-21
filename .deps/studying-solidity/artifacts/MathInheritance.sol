library MathInheritance {
    function setPercentage(uint256 number) internal pure returns (uint256) {
        return number * 100;
    }

    function getPercentage(uint256 number) internal pure returns (uint256) {
        return number / 100;
    }
}
