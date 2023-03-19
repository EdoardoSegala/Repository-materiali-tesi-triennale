contract PullPayment {
    address payable public proprietario;
    mapping (address => uint256) saldo;

    constructor() {
        proprietario = payable(msg.sender);
    }

    function inviaPull() public payable {
        saldo[msg.sender] += msg.value;
    }    
   
    function ritira(address indirizzo , uint256 somma) public{
        require(msg.sender == proprietario, "non sei il proprietario");
        require(saldo[indirizzo]>0, "nessun pagamento in attesa");
        saldo[indirizzo] -= somma;
        proprietario.transfer(somma);
    } 
}