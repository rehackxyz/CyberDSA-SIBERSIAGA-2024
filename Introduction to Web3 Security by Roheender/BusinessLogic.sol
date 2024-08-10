// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract BusinessLogicVulnerableContract {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasClaimedReward;
    address constant targetAddress = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

    constructor(address attacker) payable {
        owner = msg.sender;
        require(msg.value == 2 ether, "Must send 2 ether to initialize contract");
        balances[attacker] = 1 ether;
    }

    // Attacker address = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

    // Function to deposit Ether into the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some ether");
        balances[msg.sender] += msg.value;
    }

    // Function to claim a reward
    function claimReward() public {
        require(balances[msg.sender] > 0, "No balance to claim reward");

        balances[msg.sender] += 1 ether;
        hasClaimedReward[msg.sender] = true;

        // Transfer reward to the user
        payable(msg.sender).transfer(1 ether);
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
