// SPDX-License Identifier: GPL-3.0
pragma solidity ^0.8.2;

contract Main {

    function helloWorld() public pure returns (string memory) {
        return "hello world";
    }

    constructor() {
        helloWorld();
    }
}