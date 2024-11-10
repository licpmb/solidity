// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Subasta {
    //Se deben crear las variables de estado: valorInicial, fechaInicio y tiempoDuracion
    uint256 public valorInicial;
    uint256 public fechaInicio;
    uint256 public tiempoDuracion;
    uint256 private mayorOferta;
    address private ofertanteGanador;
    uint8 public semaforo;
    address public owner;
    mapping (address => uint256) public valorMetido;

    constructor() {
        owner = msg.sender;
        valorInicial = 1 gwei;
        fechaInicio = block.timestamp;
        tiempoDuracion = fechaInicio + 7 days;
    }

    // Mostrar el ofertante ganador y el valor de la oferta
    function getOferenteGanador() external view returns(address) {
        return ofertanteGanador;
    }

    function getMayorOferta() external view returns(uint256) {
        return mayorOferta;
    }

    function setOferta() external payable {
        require(semaforo==0,"La subasta ha finalizado");
        uint256 _valorOfertado = msg.value;
        require(_valorOfertado>valorInicial,"Valor menor al inicial");
        if(_valorOfertado > mayorOferta) {
            address _addrOferente = msg.sender;
            mayorOferta = _valorOfertado;
            ofertanteGanador = _addrOferente;
            valorMetido[_addrOferente] += _valorOfertado;
        } else {
            revert("No superaste la mayor oferta");
        }
    }

    function FinalizarSubasta( ) external {
        require(owner==msg.sender,"Usted no tiene permisos para finalizar la subasta");
        semaforo = 1;
    }
}
