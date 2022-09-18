// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./itMaps.sol";

contract Token{
    using IterableMapping for IterableMapping.Map;

    uint256 private _totalTokens;

    mapping(address => bool) private owners;
    uint256 public ownersCount;

    IterableMapping.Map private balances;
    mapping(address => uint256) private withdrawBalances;

    string private _name = "Fourth Ivasiuk Token";
    string private _symbol = "IVS3";
    uint8 private _decimals = 18;

    address public candidate;
    bool public voting;
    uint256 private votesCountFor;
    uint256 private votesCountAgainst;

    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external view returns(uint256){
        return _decimals;
    }

    function totalSupply() external view returns(uint256){
        return _totalTokens;
    }

    function balanceOf(address account) public view returns(uint256){
        return balances.get(account);
    }

    function transfer(address to, uint256 amount) external enoughTokens(msg.sender, amount){
        balances.set(msg.sender, balances.get(msg.sender) - amount);
        balances.set(to, balances.get(to) + amount);
        emit Transfer(msg.sender, to, amount);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Not enough tokens");
        _;
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Not and owner");
        _;
    }

    constructor(){
        owners[msg.sender] = true;
        ownersCount++;
        mint(20, msg.sender);
    }

    function allowance(address _owner, address _spender) external view returns(uint256){
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external{
        allowances[msg.sender][_spender] = _amount;
    }

    function mint(uint256 tokenAmount, address _to) public onlyOwner {
        balances.set(_to, balances.get(_to) + tokenAmount*(10**_decimals));
        _totalTokens += tokenAmount*(10**_decimals);
        emit Transfer(address(0), _to, tokenAmount*(10**_decimals));
    }

    function transferFrom(address sender, address recepient, uint256 amount) public enoughTokens(sender, amount){
        require(allowances[sender][msg.sender] >= amount, "You can't transfer this amount of tokens");
        allowances[sender][msg.sender] -= amount;

        balances.set(sender, balances.get(sender) - amount);
        balances.set(recepient, balances.get(recepient) + amount);
        emit Transfer(sender, recepient, amount);
    }

    function setCandidate(address _new) external onlyOwner {
        require(voting == false, "The voting is started");
        voting = true;
        candidate = _new;
    }

    function vote(bool _choose) external onlyOwner {
        require(voting == true, "Voting isn't started");

        if(_choose == true){
            votesCountFor++;
        }
        else{
            votesCountAgainst++;
        }
            
        if(votesCountFor > ownersCount/2 || votesCountAgainst > ownersCount/2){
            if(votesCountFor > ownersCount/2){
                owners[candidate] = true;
                ownersCount++;
            }
            candidate = address(0);
            voting = false;
            votesCountFor = 0;
            votesCountAgainst = 0;
        }
    }

    receive () external payable {
        uint256 value = msg.value;
         for(uint256 i=0; i < balances.size(); i++){
            address _key = balances.getKeyAtIndex(i);
            withdrawBalances[_key] += value * balances.get(_key) / _totalTokens;
         }
    }

    function checkWithdrawBalance() external view returns(uint256) {
        return withdrawBalances[msg.sender];
    }

    function withdraw(uint256 _amount) external{
        require(withdrawBalances[msg.sender] >= _amount, "Not enough tokens on withdraw balance");
        withdrawBalances[msg.sender] -= _amount;
        balances.set(msg.sender, balances.get(msg.sender) + _amount);
        payable(address(msg.sender)).transfer(_amount);
        emit Transfer(address(this), msg.sender, _amount);
    }

    function getHolderByIndex(uint256 _index) external view returns(address){
        return balances.getKeyAtIndex(_index);
    }

    function holdersCount() external view returns(uint256){
        return balances.size();
    }
}