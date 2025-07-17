//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Token {
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // 设置总供给和空投总量
    uint256 public totalAirdrop = 50000;
    uint256 public airdropPerUser = 50;
    uint256 public totalSupply = 100000000+totalAirdrop;


    //设置所有者和空投箱
    address private _owner;
    address private _airdropBox;

    //kv：空投领取记录和余额表
    mapping(address => bool) airdropClaimLog;
    mapping(address => uint256) balances;

    //通知事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Destroy(address indexed addr, uint256 amount);


    constructor(address airdropBoxAddr) {
        require(airdropBoxAddr != address(0), "Airdrop box address cannot be the zero address");
        uint256 ownerSupply = totalSupply - totalAirdrop;
        _owner = msg.sender;//之后鉴权用
        _airdropBox = airdropBoxAddr;

        balances[_owner] = ownerSupply;
        emit Transfer(address(0), _owner, ownerSupply);
        balances[_airdropBox] = totalAirdrop;
        emit Transfer(address(0), _airdropBox, totalAirdrop);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function airdropBox() public view returns (address) {
        return _airdropBox;
    }


    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");

        //修改余额
        balances[msg.sender] -= amount;
        balances[to] += amount;

        //通知
        emit Transfer(msg.sender, to, amount);
    }

    function getBalance(address account) external view returns (uint256) {
        return balances[account];
    }


    function claimAirdrop(address to) external {
        require(balances[_airdropBox] >= airdropPerUser, "Airdrop box is empty");
        require(!airdropClaimLog[to], "You have already claimed the airdrop");
        
        //给空投
        balances[to] += airdropPerUser;
        balances[_airdropBox] -= airdropPerUser;


        //记录领取过的地址
        airdropClaimLog[to] = true;

       
        emit Transfer(_airdropBox, to, airdropPerUser);
    }

  /**For admin */

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner{
        //总供给+ 目标地址+
        totalSupply += amount;
        balances[to] += amount;
  
        emit Transfer(address(0), to, amount);
    }

    function destroy(address addr, uint256 amount) external onlyOwner{
        require(balances[addr] >= amount, "Not enough tokens");
        //总供给- 目标地址-
        totalSupply -= amount;
        balances[addr] -= amount;
        //被销毁的地址给黑洞转账，亦是销毁，所以两个通知
        emit Transfer(addr ,address(0), amount);
        emit Destroy(addr, amount);
    }
}