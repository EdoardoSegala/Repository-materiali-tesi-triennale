   contract banca{
    //si mappa l'indirizzo del wallet al suo bilancio in wei
    mapping(address => uint) public bilancio;

    //si inserisce nell'array di mapping l'indirizo dell'utente e il valore della transazione 
    function deposita() public payable{
        balances[msg.sender] += msg.value; 
    }
    //l'utente consulta
    function getBilancio() public view returns(uint){
        return address(this).bilancio;
    }
} 