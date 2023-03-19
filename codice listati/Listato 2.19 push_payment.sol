contract PushPayment {
    address payable public proprietario;

    constructor() {
        proprietario = payable(msg.sender);
    }
    
    function inviaPush() public payable {
        proprietario.transfer(msg.value);
    }
}