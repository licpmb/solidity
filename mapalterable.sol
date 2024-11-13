// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Mapa {
    uint public counter;
    mapping (uint => address) public listaAddress;
    //len = arrayAddress.length;
    address[] arrayAddress; // for(i=0; i<len; i++)

    function loop() public view {
        uint256 _counter = counter;
        for(uint i=0; i< counter; i++){
            address devolver = listaAddress[i];
        }
    }

}