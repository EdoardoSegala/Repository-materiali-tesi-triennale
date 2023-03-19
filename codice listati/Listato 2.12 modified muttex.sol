  modifier mutex() {
        require(!lock, "locked");
        lock = true;
        _; 
        lock = false; }   
    function ritira() public mutex {
        uint bal = conti[msg.sender];
        require(bal > 0); //il bilancio deve essere maggiore di 0
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        conti[msg.sender] = 0; //si agiorna il conto a 0
    }