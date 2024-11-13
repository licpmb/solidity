// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Subasta {
    address private owner;
    uint private duracionSubasta;
    uint private mejorOferta;
    address private mejorOfertante;
    bool private subastaFinalizada;
    uint private tiempoExtensionSubasta = 10 minutes;
    uint private comision = 2;

    struct Oferta {
        address ofertante;
        uint montoOferta;
    }

    Oferta[] private ofertas;
    mapping(address => uint) private devolucionesPendientes;

    event NuevaOferta(address indexed ofertante, uint montoOferta, uint nuevaMejorOferta);
    event SubastaFinalizada(address ganador, uint montoOferta);
    event DepositoDevuelto(address indexed ofertante, uint montoDevuelto);

    modifier soloOwner() {
        require(msg.sender == owner, "Solo el propietario puede realizar esta accion");
        _;
    }

    modifier subastaActiva() {
        require(block.timestamp < duracionSubasta, "La subasta ya ha finalizado");
        _;
    }

    constructor(uint _tiempoSubasta) {
        require(_tiempoSubasta > 0, "La duracion de la subasta debe ser mayor a 0");
        owner = msg.sender;
        duracionSubasta = block.timestamp + _tiempoSubasta;
    }

    function ofertar() external payable subastaActiva {
        require(msg.value > 0, "La oferta debe ser mayor a 0");
        require(msg.value > mejorOferta * 105 / 100, "La oferta debe ser al menos un 5% mayor que la oferta actual");

        if (mejorOferta != 0) {
            devolucionesPendientes[mejorOfertante] += mejorOferta;
        }

        mejorOfertante = msg.sender;
        mejorOferta = msg.value;
        ofertas.push(Oferta(msg.sender, msg.value));

        if (block.timestamp > duracionSubasta - 10 minutes) {
            duracionSubasta += tiempoExtensionSubasta;
        }

        emit NuevaOferta(msg.sender, msg.value, mejorOferta);
    }

    function retirar() external {
        uint montoOferta = devolucionesPendientes[msg.sender];
        require(montoOferta > 0, "No hay fondos para retirar");

        devolucionesPendientes[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: montoOferta}("");
        require(success, "Transferencia fallida");

        emit DepositoDevuelto(msg.sender, montoOferta);
    }

    function finalizarSubasta() external soloOwner {
        require(block.timestamp >= duracionSubasta, "La subasta aun no ha finalizado");
        require(!subastaFinalizada, "La subasta ya ha sido finalizada");

        subastaFinalizada = true;
        emit SubastaFinalizada(mejorOfertante, mejorOferta);

        uint montoComision = mejorOferta * comision / 100;
        uint montoFinal = mejorOferta - montoComision;

        (bool success, ) = owner.call{value: montoFinal}("");
        require(success, "Transferencia fallida");
    }

    function obtenerOfertas() external view returns (Oferta[] memory) {
        return ofertas;
    }

    function obtenerGanador() external view returns (address, uint) {
        require(subastaFinalizada, "La subasta aun no ha finalizado");
        return (mejorOfertante, mejorOferta);
    }
}
