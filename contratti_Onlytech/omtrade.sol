pragma solidity ^0.5.12;

/**
 * @author The I <info@thei.it>
 * @title OmTrade
 */ 
 
 contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract OmTrade is Pausable {
    uint256 marketFee;

    /* map token with token winners/price */
    mapping (uint256 => AllowedBuyer) internal allowedBuyers;

    /* Keep track of how much any shareholder earned */
    mapping (address => uint256) internal shareholdersWallet;

    struct ShareHolder {
        address wallet;
        uint256 share;
    }
	
    /* Map token with shareholder */
    mapping(uint256 => ShareHolder[]) internal shareHolders;

    function setShares(uint256 _tokenId, address[] memory _shareholders, uint256[] memory _shares) onlyOwner public {
        require(_shareholders.length == _shares.length, "The list of shares holders and shares must be the same");
        
        uint256 totalShares;
        for (uint256 i = 0; i < _shares.length; i++) {
            totalShares += _shares[i];
        }

        for (uint256 i = 0; i < _shareholders.length; i++) {
            _addShareholder(_tokenId, _shareholders[i], _shares[i]);
        }

        emit SharesSet(_tokenId, msg.sender);
    }

    function _addShareholder(uint256 _tokenId, address _shareholder, uint256 _share) private {
        require(_shareholder != address(0), "Shareholder address cannot be 0x0");
        require(_share > 0, "Share cannot be 0");

        shareHolders[_tokenId].push(ShareHolder(_shareholder, _share));
        // shares[_tokenId][_shareholder] = _share;
    }

    struct AllowedBuyer {
        address buyer;
        uint256 price;
    }
    
    constructor(uint256 _marketFee) public payable {
        marketFee = _marketFee;
    }
    
    event Buy(address _from, address _to, uint256 _amount, uint256 _tokenId);
    event Pay(address _from, uint256 _amount);
    event SharesSet(uint256 _tokenId, address _from); // _from allows to understand whether the backend or the final user set the shares, if it was the backend then we are lazy minting
    event Withdraw(address _to, uint _amount);
    event ChangeMarketFee(uint _newMarketFee);
    event LazyBuy(address _from, address _to, uint256 _amount, uint256 _omTokenId);
    event LazyPayShares(uint256 _tokenId, uint256 _amount, address owner);
    event ShareholderWithdraw(address _shareholderWalelt, uint256 _amountToWithdraw);
    
    // Allow contract to receive money
	function () external payable {}

    /**
     * @dev setAllowedBuyer is called by the owner. Set if address can actually pay for a token
     * If not call refund.
     * @param _buyer is the buyer
     * @param _price is amount of eth paid
     * @param _tokenId is the token sold
     */
     // XXX: fallisce nel caso di collectibles con più buyer. Pensare a una soluzione.
    function setAllowedBuyer(address _buyer, uint256 _price, uint256 _tokenId) onlyOwner external {
        allowedBuyers[_tokenId] = AllowedBuyer(_buyer, _price);
    }

    // XXX: due versioni di buy. Una controlla il costo e il buyer, l'altra no. Da valutare a livello di costo buy2 e setAllowedBuyer

    /**
     * @dev buy1 is called by the buyer. Check if the price is correct performed externally. Amount stays in the contract.
     * @param _from is the buyer
     * @param _amount is amount of eth paid
     * @param _tokenId is the token sold
     */
    function buy1(address payable _from, address payable _to, uint256 _amount, uint256 _tokenId) whenNotPaused external payable{
        require(msg.value == _amount, "Declared amount differs from actual amount");
        
        uint256 marketFeeValue = msg.value / 100 * marketFee;
        uint256 nftPrice = msg.value;

        // OMX fee and substract it from the remaining price
        address(this).transfer(marketFeeValue);
        nftPrice = nftPrice - marketFeeValue;

        // Shareholders fees
        for (uint256 i = 0; i < shareHolders[_tokenId].length; i++) {
            uint256 shareHolderFee = nftPrice / 100 * shareHolders[_tokenId][i].share;
            shareholdersWallet[shareHolders[_tokenId][i].wallet] += shareHolderFee;
            nftPrice -= shareHolderFee;
        }

        _to.transfer(nftPrice);
        emit Buy(_from, _to, _amount, _tokenId);
    }

      /**
     * @dev buy1 is called by the buyer. Check if the price is correct performed externally. Amount stays in the contract.
     * @param _from is the buyer
     * @param _amount is amount of eth paid
     * @param _omTokenId the if (primary key) of the nft in our servers
     */
    function lazy_buy(address payable _from, address payable _to, uint256 _amount, uint256 _omTokenId) whenNotPaused external payable{
        address(this).transfer(msg.value);
        emit LazyBuy(_from, _to, _amount, _omTokenId);
    }

    /**
     * @dev buy1 is called by the buyer. Check if the price is correct performed externally. Amount stays in the contract.
     * @param _amount is amount of eth paid in lazy_buy function
     * @param _tokenId id of the minted token
     * @param owner new owner on the nft
     */
    function lazy_pay_shares(uint256 _tokenId, uint256 _amount, address payable owner) external payable {
        uint256 marketFeeValue = _amount / 100 * marketFee;
        uint256 nftPrice = _amount;

        // OMX fee and substract it from the remaining price
        address(this).transfer(marketFeeValue);
        nftPrice = nftPrice - marketFeeValue;
        
        // Shareholders fees
        for (uint256 i = 0; i < shareHolders[_tokenId].length; i++) {
            uint256 shareHolderFee = nftPrice / 100 * shareHolders[_tokenId][i].share;
            shareholdersWallet[shareHolders[_tokenId][i].wallet] += shareHolderFee;
            nftPrice -= shareHolderFee;
        }

        owner.transfer(nftPrice);
        emit LazyPayShares(_tokenId, _amount, owner);
    }
    
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    
    /**
     * @dev buy2 is called by the buyer. Amount stays in the contract.
     * @param _from is the buyer
     * @param _amount is amount of eth paid
     * @param _tokenId is the token sold
     */
    function buy2(address _from, address payable _to, uint256 _amount, uint256 _tokenId) whenNotPaused payable external {
        require(allowedBuyers[_tokenId].buyer == _from);
        require(allowedBuyers[_tokenId].price == _amount);

        uint256 marketFeeValue = msg.value / 100 * marketFee;
        // amountDue[_to] -= marketFeeValue;
        
        address(this).transfer(marketFeeValue);
        _to.transfer(msg.value-marketFeeValue);

        emit Buy(_from, _to, _amount, _tokenId);
    }

    /**
     * @dev pay is called by the owner. Send amount to users (sellers)
     * @param _to is the beneficiary
     * @param _amount is amount of eth paid
     */
    function pay(address payable _to, uint256 _amount) onlyOwner external {
        require(_to != address(this) && _to != address(0x0));
        
        _to.transfer(_amount);
        emit Pay(_to, _amount);
    }

    /**
     * @dev withdraw is called by the owner.
     * @param _amount is amount of eth paid
     */
    function withdraw(uint256 _amount) external {
        msg.sender.transfer(_amount);

        emit Withdraw(msg.sender, _amount);
    }
    
    function changeMarketFee(uint256 _newMarketFee) onlyOwner external {
        marketFee = _newMarketFee;
    }

    function shareholderWithdraw(uint256 _amountToWithdraw) external {
        require(shareholdersWallet[msg.sender] < _amountToWithdraw);

        shareholdersWallet[msg.sender] -= _amountToWithdraw;
        address(msg.sender).transfer(_amountToWithdraw);
        
        emit ShareholderWithdraw(msg.sender, _amountToWithdraw);
    }
}