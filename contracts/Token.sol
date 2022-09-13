// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./itMaps.sol";

contract Token{
    using IterableMapping for IterableMapping.Map;

    uint256 _totalTokens;
    address[] public owners;
    uint256 public ownersCount;
    //mapping(address => uint256) balances;
    IterableMapping.Map balances;
    //IterableMapping.Map withdrawBalances;
    mapping(address => uint256) withdrawBalances;
    string _name = "Fourth Ivasiuk Token";
    string _symbol = "IVS3";
    address public candidate;
    bool public voting;
    mapping(address => bool) ownersVotes;
    uint256 votesCountFor;
    uint256 votesCountAgainst;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external pure returns(uint256){
        return 18;
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
        bool flag;
        for(uint256 i = 0; i < ownersCount; i++){
            if(msg.sender == owners[i]){
                flag = true;
                break;
            }
        }
        require(flag == true, "Not and owner");
        _;
    }

    constructor(){
        owners.push(msg.sender);
        ownersCount++;
        ownersVotes[msg.sender] = false;
        mint(20 ether, msg.sender);
    }

    function mint(uint amount, address _to) public onlyOwner {
        balances.set(_to, balances.get(_to) + amount);
        _totalTokens += amount;
        emit Transfer(address(0), _to, amount);
    }

    function transferFrom(address sender, address recepient, uint256 amount) public enoughTokens(sender, amount){
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
        require(ownersVotes[msg.sender] == false, "This owner voted");
        ownersVotes[msg.sender] = true;
        if(_choose == true){
            votesCountFor++;
        }
        else{
            votesCountAgainst++;
        }
            
        if(votesCountFor > ownersCount/2 || votesCountAgainst > ownersCount/2){
            if(votesCountFor > ownersCount/2){
                owners.push(candidate);
                ownersCount++;
            }
            candidate = address(0);
            voting = false;
            votesCountFor = 0;
            votesCountAgainst = 0;
            for(uint256 i=0; i<owners.length; i++){
                ownersVotes[owners[i]] = false;
            }
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
}