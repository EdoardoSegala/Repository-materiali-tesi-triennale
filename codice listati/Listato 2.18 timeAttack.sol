contract GuessTheTime{
    uint public ultimo_blocco;

    constructor() payable {} 

    function indovina(uint n) external payable{
        require(ultimo_blocco != block.timestamp);
        ultimo_blocco = block.timestamp;
        if(n == block.timestamp){
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");         
            require(sent, "Failed to send Ether");     
        }
    }
}