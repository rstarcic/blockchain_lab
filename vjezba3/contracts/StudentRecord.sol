// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract StudentRecord {
    struct Student {
        string name;
        uint grade;
    }

    mapping(uint => Student) public students;
    mapping(address => uint) public balances;
    uint public count;

    address public owner;

    constructor() {
        owner = msg.sender; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    function getBalance(address _user) public view returns (uint) {
        return balances[_user];
    } 

    function sendMoney(address send_to,  uint _amount) public {
        require(balances[msg.sender] >= _amount, "Not enough balance");
        require(send_to != address(0), "Invalid address");

        balances[msg.sender] -= _amount;
        balances[send_to] += _amount;
    }

    function withdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount, "Not enough funds");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function addStudent(string memory _name, uint _grade) public onlyOwner {
        students[count] = Student(_name, _grade);
        count++;
    }

    function getStudent(uint _id) public view returns (string memory, uint) {
        Student memory s = students[_id];
        return (s.name, s.grade);
    }

    function updateGrade(uint _id, uint _newGrade) public onlyOwner {
        require(_id < count, "Student does not exist");
        students[_id].grade = _newGrade;
    }
}
