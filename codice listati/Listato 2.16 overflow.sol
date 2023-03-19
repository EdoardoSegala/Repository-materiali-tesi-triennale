contract IntegerOverflow {
    uint256 public saldo = 1000;
    function aggiungi(uint n) public {
        saldo += n; // potenziale bug }}