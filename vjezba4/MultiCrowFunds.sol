// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiCrowdFund {
    struct Campaign {
        string title;
        address owner;
        uint goal;
        uint deadline;
        uint totalRaised;
        bool goalReached;
        bool fundsWithdrawn;
        mapping(address => uint) contributions;
    }

    uint public campaignCount;
    mapping(uint => Campaign) public campaigns;

    event Donated(address indexed donor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event Refunded(address indexed donor, uint amount);

    function createCampaign(string memory _title, uint _goal, uint _durationMinutes) external {
        require(_goal > 0, "Goal must be > 0");
        require(_durationMinutes > 0, "Duration must be > 0");

        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.title = _title;
        newCampaign.owner = msg.sender;
        newCampaign.goal = _goal * 1 ether;
        newCampaign.deadline = block.timestamp + (_durationMinutes * 1 minutes);
        campaignCount++;
    }

    function donateTo(uint campaignId) external payable {
        Campaign storage c = campaigns[campaignId];
        require(block.timestamp < c.deadline, "Campaign ended");
        require(msg.value > 0, "Donation must be greater than 0");

        c.contributions[msg.sender] += msg.value;
        c.totalRaised += msg.value;
        if (c.totalRaised >= c.goal) c.goalReached = true;

        emit Donated(msg.sender, msg.value);
    }

    function withdrawFunds(uint campaignId) external {
        Campaign storage c = campaigns[campaignId];
        require(msg.sender == c.owner, "Not owner");
        require(block.timestamp >= c.deadline, "Campaign not ended");
        require(c.goalReached, "Goal not reached");
        require(!c.fundsWithdrawn, "Already withdrawn");

        uint amount = c.totalRaised;
        c.fundsWithdrawn = true;
        payable(c.owner).transfer(amount);

        emit FundsWithdrawn(c.owner, amount);
    }

    function refund(uint campaignId) external {
        Campaign storage c = campaigns[campaignId];
        require(block.timestamp >= c.deadline, "Campaign still running");
        require(!c.goalReached, "Goal was reached");

        uint amount = c.contributions[msg.sender];
        require(amount > 0, "Nothing to refund");

        c.contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Refunded(msg.sender, amount);
    }

    function getCampaign(uint id) external view returns (
        string memory title,
        address owner,
        uint goal,
        uint deadline,
        uint totalRaised,
        bool goalReached,
        bool fundsWithdrawn
    ) {
        Campaign storage c = campaigns[id];
        return (c.title, c.owner, c.goal, c.deadline, c.totalRaised, c.goalReached, c.fundsWithdrawn);
    }
}
