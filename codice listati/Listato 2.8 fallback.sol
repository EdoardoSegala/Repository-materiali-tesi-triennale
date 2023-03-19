contract EthDeposit {
    mapping(address => uint) public conti;
    //gli utenti depositano eth con questa funzione
    function deposita() public payable {
        conti[msg.sender] += msg.value;
    }

    
    //gli utenti ritirano il proprio eth
    function ritira() public {
        uint bal = conti[msg.sender];
        require(bal > 0); //il bilancio deve essere maggiore di 0
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed_to_send_Ether");
        conti[msg.sender] = 0; //si agiorna il conto a 0
    }
}