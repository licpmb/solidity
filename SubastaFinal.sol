/*
Subasta - Trabajo Final Buenos Aires 
Se requiere un contrato inteligente verificado y publicado en la red de Scroll Sepolia que cumpla con lo siguiente:
Funciones: Constructor.
Inicializa la subasta con los parámetros necesarios para su funcionamiento. 
Función para ofertar: Permite a los participantes ofertar por el artículo.
Para que una oferta sea válida debe ser mayor que la mayor oferta actual al menos en 5% y debe realizarse mientras la subasta esté activa.
 Mostrar ganador: Muestra el ofertante ganador y el valor de la oferta ganadora. 
Mostrar ofertas: Muestra la lista de ofertas y los montos ofrecidos. 
Devolver depósitos: Al finalizar la subasta se devuelve el depósito a los ofertantes que no ganaron, descontando una comisión del 2% para el gas. 
Manejo de depósitos: Las ofertas se depositan en el contrato y se almacenan con las direcciones de los ofertantes. 
Eventos: 
Nueva Oferta: Se emite cuando se realiza una nueva oferta. 
Subasta Finalizada: Se emite cuando finaliza la subasta.
 Funcionalidades avanzadas: 
Reembolso parcial: Los participantes pueden retirar de su depósito el importado por encima de su última oferta durante el desarrollo de la subasta. 
Consideraciones adicionales: 
Se debe utilizar modificadores cuando sea conveniente. Para superar a la mejor oferta la nueva oferta debe ser superior al menos en 5%. 
El plazo de la subasta se extiende en 10 minutos con cada nueva oferta válida. Esta regla se aplica siempre a partir de 10 minutos antes del plazo original de la subasta. De esta manera los competidores tienen tiempo suficiente para presentar una nueva oferta si así lo desean.
 El contrato debe ser seguro y robusto, manejando adecuadamente los errores y las posibles situaciones excepcionales. Se deben utilizar eventos para comunicar los cambios de estado de la subasta a los participantes. La documentación del contrato debe ser clara y completa, explicando las funciones, variables y eventos. IMPORTANTE: El trabajo debe ser presentado en la sección TRABAJO FINAL MÓDULO 2, donde sólo se debe incluir la URL correspondiente del contrato inteligente que cumpla con los requisitos definidos en esta sección que debe estar publicado y verificado.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubastaFinal {
    address public owner;
    uint public duracionSubasta;
    uint public mejorOferta;
    address public mejorOfertante;
    bool public subastaFinalizada; //Estado si/no de la subasta
    uint public tiempoExtensionSubasta = 10 minutes;
    uint public comision = 2;

    struct Oferta {
        address ofertante;
        uint montoOferta;
    }

    Oferta[] public ofertas;
    mapping(address => uint) public devolucionesPendientes;

    event NuevaOferta(address indexed ofertante, uint montoOferta);
    event SubastaFinalizada(address ganador, uint montoOferta);

    modifier soloOwner() {
        require(msg.sender == owner, "Solo el propietario puede modificar la subasta");
        _;
    }

    modifier subastaActiva() {
        require(block.timestamp < duracionSubasta, "La subasta ya ha finalizado");
        _;
    }

    constructor(uint _tiempoSubasta) {
        owner = msg.sender;
        duracionSubasta = block.timestamp + _tiempoSubasta;
    }

    function ofertar() external payable subastaActiva {
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

        emit NuevaOferta(msg.sender, msg.value);
    }

    function retirar() external {
        uint montoOferta = devolucionesPendientes[msg.sender];
        require(montoOferta > 0, "No hay fondos para retirar");

        devolucionesPendientes[msg.sender] = 0;

        payable(msg.sender).transfer(montoOferta);
    }

    function finalizarSubasta() external soloOwner {
        require(block.timestamp >= duracionSubasta, "La subasta aun no ha finalizado");
        require(!subastaFinalizada, "La subasta ya ha finalizado");

        subastaFinalizada = true;
        emit SubastaFinalizada(mejorOfertante, mejorOferta);

        uint montoComision = mejorOferta * comision / 100;
        uint montoFinal = mejorOferta - montoComision;

        payable(owner).transfer(montoFinal);
    }

    function obtenerOfertas() external view returns (Oferta[] memory) {
        return ofertas;
    }

    function obtenerGanador() external view returns (address, uint) {
        require(subastaFinalizada, "La subasta aun no ha finalizado");
        return (mejorOfertante, mejorOferta);
    }
}
