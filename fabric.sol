// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract ChildContract{
    uint public number;
    
    constructor(uint _number) {
        number = _number;
    }
}

contract Factory {

    ChildContract[] public children;
    function createChild(uint _number) external {
        ChildContract child = new ChildContract (_number);
        children.push(child);
    }
}