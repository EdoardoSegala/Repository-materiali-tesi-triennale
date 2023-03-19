//creazione di un contratto
contract Mycontract{

    //automaticamente ci aspettiamo l'index
    uint256 public peopleCount=0;
    mapping(uint =>Person) public people;

    //si potrebbe vederlo come un database  
    //uint si tratta della key e person il value 
    
    struct Person{
    uint _id;
      string _firstname;
      string _lastname;
    }
    
    //aggiungo una persona all'array
    function addPerson(string memory _firstname,string memory _lastname) public{
    
       peopleCount += 1;
        people[peopleCount] = Person(peopleCount,_firstname,_lastname);       
    }
}