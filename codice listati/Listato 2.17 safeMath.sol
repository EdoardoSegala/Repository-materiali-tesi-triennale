import "@openzeppelin/contracts/utils/math/SafeMath.sol"; 
contract IntegerOverflow {
    using SafeMath for uint;
    uint public saldo = 1000;
    function aggiungi(uint n) public {
        saldo = saldo.add(n); // bug risolto
    }
}