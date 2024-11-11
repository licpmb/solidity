// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Donaciones {

    struct Donacion {
        address donante;
        uint cantidad;
        uint fecha;
    }
    Donacion[] public donaciones;
    mapping (address => uint256) public balance;
    address[] public uniqueAddr;

/*
    Emitir un evento DonacionRealizada que incluya:
    La dirección del donante.
    La cantidad de ether donada.
    La fecha de la donación.
*/
    event DonacionRealizada(address indexed donante, uint256 cantidad, uint256 timestamp);

/*
Una función donar() que permita a los usuarios enviar ether al contrato. 
Esta función debe:
Aceptar ether (debe ser payable).
Crear un nuevo registro en el array de donaciones.
Actualizar el mapping para reflejar el total donado por el donante.
Emitir el evento DonacionRealizada.
*/
    function donar() external payable {
        donaciones.push(Donacion(msg.sender,msg.value,block.timestamp));
        if(balance[msg.sender]==0) {
            uniqueAddr.push(msg.sender);
        }
        balance[msg.sender] +=  msg.value;
        emit DonacionRealizada(msg.sender,msg.value,block.timestamp);
    }

/*
Una función obtenerDonaciones() que retorne el total de 
donaciones realizadas y el número de donantes únicos.
*/
    function obtenerDonaciones() external view returns (Donacion[] memory _donaciones) {
        uint256 len = uniqueAddr.length;
        for(uint256 i=0; i< len; i++) {
            _donaciones[i] = Donacion(uniqueAddr[i],balance[uniqueAddr[i]],block.timestamp);
        }
        return _donaciones;
    }

}