// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowFund {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalRaised;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint) public contributions;
    
    event Donated(address indexed donor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event Refunded(address indexed donor, uint amount);

    constructor(uint _goal, uint _durationMinutes) {
        owner = msg.sender;
        goal = _goal * 1 ether;
        deadline = block.timestamp + (_durationMinutes * 1 minutes);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier campaignActive() {
        require(block.timestamp < deadline, "Campaign ended");
        _;
    }

    modifier campaignEnded() {
    require(block.timestamp >= deadline, "Campaign still running");
    _;
    }


    function donate() external payable campaignActive {
        require(msg.value > 0, "Donation must be greater than 0");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        if (totalRaised >= goal) {
            goalReached = true;
        }

        emit Donated(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyOwner campaignEnded{
        require(goalReached, "Goal not reached");
        require(!fundsWithdrawn, "Already withdrawn");
        fundsWithdrawn = true;
        payable(owner).transfer(address(this).balance);
        emit FundsWithdrawn(owner, address(this).balance);
    }
   
    function refund() external campaignEnded {
        require(!goalReached, "Goal reached, no refunds");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Refunded(msg.sender, amount);
    }
        

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getTimeLeft() external view returns (uint) { 
        if(block.timestamp > deadline) return 0;
        return deadline - block.timestamp;
    }
        
}