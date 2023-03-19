pragma solidity ^0.8.0;

//creazione del contratto
contract HelloWorld {
    string public message;
    
    //costruttore del contratto 
    constructor() {
    //setta il parametro message quando viene creato il contratto
        message = "Hello,World!";
    }
    
    function printMsg() public view returns (string memory) {
        return message;
    }
}