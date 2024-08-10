// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract AccessControl {
    address public owner;
    mapping(address => uint256) public balances;
    address constant targetAddress = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

    constructor(address _deadpool, address _wolverine) payable {
        owner = msg.sender;
        require(msg.value == 2 ether, "Must send 2 ether to initialize contract");
        balances[_deadpool] = 1 ether;
        balances[_wolverine] = 1 ether;
    }

    // Deadpool address = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // Wolverine address = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    // Attacker address = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

    // Function to deposit Ether into the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some ether");
        balances[msg.sender] += msg.value;
    }

    // Vulnerable function that allows attacker to steal funds
    function withdraw(uint256 amount, address from, address to) public {
        require(balances[from] >= amount, "Insufficient balance");

        // Vulnerable access control: any user can withdraw from any account
        balances[from] -= amount;
        balances[to] += amount;  // Update the internal balance mapping

        // Transfer the amount to the 'to' address
        payable(to).transfer(amount);
    }

    // Function to get balance of an address
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    // Function to check if the challenge is solved
    function isSolved() public view returns (bool) {
        return balances[targetAddress] >= 2 ether;
    }
}
