pragma solidity ^0.8.0;
import "@openzeppelin/contracts@4.3.2/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.3.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.3.2/utils/math/SafeMath.sol";

//contratto che crea delle carte collezionabili nella blockchain
contract cryptoCards is ERC1155{   
    struct carta{
      uint256 id; 
      string  nome; 
      uint256 prezzo; 
      uint256 numero;
    }
    
  //si mappa un indice a una carta creando un array chiamato insieme
  mapping(uint256=>carta) public insieme;
  uint256 index = 0;
  
  //quando si avvia il contratto per la prima volta si crea il token genesi 
  address public owner;
  //constructor payable cosi possiamo inserire dell'eth nel contratto
  constructor() ERC1155('https://mockapi.io/tokens/{id}'){
         insieme[index]=carta(index,"genesi",3,5);
         _mint(msg.sender,index,5,"");
         //si assegna il proprietario
         owner = msg.sender;     
    }
    
    //funzione che aggiunge una carta all'array e la conia subito nella blockchain
   function aggiungiCarta(string memory _nome,uint256 numero,uint256 _prezzo) public restricted{
        index++;
        insieme[index]=carta(index,_nome,_prezzo,numero);
        _mint(msg.sender,index,numero,"");
   }  
   
   function compra(uint256 _id) public payable{
        require(msg.value ==insieme[_id].prezzo*10**18);//si paga in eth
         uint amount = address(this).balance;
        //il proprietario viene pagato in ethereum 
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed_to_send_Ether");
        amount = 0;    
    }
    
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
}
