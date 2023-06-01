// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;

    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;

    event Stake(address indexed wallet, uint256 indexed amount);

    bool openForWithdraw;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    function execute() public {
        if (address(this).balance >= threshold && block.timestamp > deadline) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
        if (address(this).balance < threshold) {
            openForWithdraw = true;
        }
    }

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public {
        require(openForWithdraw);
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success);
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp < deadline) {
            return (deadline - block.timestamp);
        } else {
            return (0);
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}