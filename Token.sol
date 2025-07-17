//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Token {
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // 设置总供给和空投总量
    uint256 public totalAirdrop = 50000;
    uint256 public airdrop = 50;
    uint256 public totalSupply = 100000000+totalAirdrop;


    //设置所有者和空投箱
    address public owner;
    address public airdropBox;

    //kv：空投领取记录和余额表
    mapping(address => bool) airdropClaimLog;
    mapping(address => uint256) balances;

    //通知事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Destroy(address indexed addr, uint256 amount);


    constructor() {
        //init
        balances[msg.sender] = totalSupply;
        owner = msg.sender;//之后鉴权用

        balances[airdropBox] = totalAirdrop;
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");

        //修改余额
        balances[msg.sender] -= amount;
        balances[to] += amount;

        //通知
        emit Transfer(msg.sender, to, amount);
    }


    function claimAirdrop(address to) external {
        require(balances[airdropBox] >= airdrop, "Airdrop box is empty");
        require(!airdropClaimLog[to], "You have already claimed the airdrop");
        
        //给空投
        balances[to] += airdrop;
        balances[airdropBox] -= airdrop;


        //记录领取过的地址
        airdropClaimLog[to] = true;

       
        emit Transfer(airdropBox, to, airdrop);
    }



    function getBalance(address account) external view returns (uint256) {
        return balances[account];
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can mint tokens");
        //总供给+ 目标地址+
        totalSupply += amount;
        balances[to] += amount;
  
        emit Transfer(address(0), to, amount);
    }

    function destroy(address addr, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can destroy tokens");
        require(balances[addr] >= amount, "Not enough tokens");
        //总供给- 目标地址-
        totalSupply -= amount;
        balances[addr] -= amount;
        //被销毁的地址给黑洞转账，亦是销毁，所以两个通知
        emit Transfer(addr ,address(0), amount);
        emit Destroy(addr, amount);
    }
}