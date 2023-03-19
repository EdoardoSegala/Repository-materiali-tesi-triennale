contract noAut{
    address owner;
    mapping (address=>uint) balances;
    constructor() public{//quando creo il contratto setto owner
        owner = msg.sender;
    }
    uint test =0;
    function foo() public{
        test = 10+2/2*10;
    }
    function withdraw(uint amount) public payable{
        msg.sender.transfer(amount);
    }
    //funione che per qualsiasi motivo autodistrugge il contratto
    function kill() public {
        selfdestruct(msg.sender);
    }
}