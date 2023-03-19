contract cryptoBid{
    address payable indirizzo_ultimo; //indirizzo vincitore
    uint offerta_ultima;//offerta vincitore

    function offerta() public payable {
        require(msg.value>offerta_ultima); 
        //si rimborsa il vecchio vincitore
        require(indirizzo_ultimo.send(offerta_ultima));
        //si setta il nuovo vincitore
        indirizzo_ultimo=payable(msg.sender);
        offerta_ultima=msg.value;
    }
}