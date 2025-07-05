// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract SimpleStorage {
    string name;

    function set(string memory n) public {
        name = n;
    }

    function hello() public view returns (string memory) {
        return string(abi.encodePacked("hello,", name));
    }
}