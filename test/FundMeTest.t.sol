// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; 
import {FundMe} from "../src/FundMe.sol"; 
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe fundMe; 

  address USER = makeAddr("user"); 
  uint256 constant SEND_VALUE = 0.1 ether;  
  uint256 constant STARTING_BALANCE = 10 ether;  
  uint256 constant GAS_PRICE = 1; 


  function setUp() external {
   // fundMe = new FundMe(); 
   DeployFundMe deployFundMe = new DeployFundMe(); 
   fundMe = deployFundMe.run(); 
   vm.deal(USER, STARTING_BALANCE); 
  }

  function testMinimumDollarIsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18); 
  }

  function testOwnerisMsgSender() public {
    assertEq(fundMe.getOwner(), msg.sender); 
  }

  function testPriceFeedVersionIsAccurate() public {
    uint256 version = fundMe.getVersion(); 
    assertEq(version, 4); 
  }

  function testFundFailsWithoutEnoughETH() public {
    vm.expectRevert(); 
    fundMe.fund(); 
  }

  function testFundUpdatesFundDataStructure() public {
    vm.prank(USER); // next transaction will be done by USER  

    fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); 
    assertEq(amountFunded, SEND_VALUE);  
  }

  function testAddsFunderToArrayofFunders() public {
    vm.prank(USER); // next transaction will be done by USER  
    fundMe.fund{value: SEND_VALUE}();

    address funder = fundMe.getFunder(0); 
    assertEq(funder, USER); 

  }

  modifier funded() {
    vm.prank(USER); 
    fundMe.fund{value: SEND_VALUE}();
    _; 
  }

  function testOnlyOwnerCanWithdraw() public funded {
    vm.expectRevert(); 
    vm.prank(USER);
    fundMe.withdraw(); 
  }

  function testWithdrawWithASingleFunder() public funded {
    // Logic of test: 
    //Arrange
    uint256 startingOwnerBalance = fundMe.getOwner().balance; 
    uint256 startingFundMeBalance = address(fundMe).balance; 

    //Act
    // uint256 gasStart = gasleft(); 
    vm.txGasPrice(GAS_PRICE); 
    vm.prank(fundMe.getOwner()); 
    fundMe.withdraw(); 

    // uint256 gasEnd = gasleft(); 
    // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; 
    // console.log("gasUsed: ", gasUsed); 

    // Assert 
    uint256 endingOwnerBalance = fundMe.getOwner().balance; 
    uint256 endingFundMeBalance = address(fundMe).balance; 
    assertEq(endingFundMeBalance, 0); 
    assertEq(
      startingFundMeBalance + startingOwnerBalance, 
      endingOwnerBalance); 
  }

   function testWithdrawWithFromMultipleFunders() public funded {
    // Logic of test: 
    //Arrange
    uint160 numberOfFunders = 10; 
    uint160 startingFunderIndex = 1; 

    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
      hoax(address(i), SEND_VALUE); // = vm.prank + vm.deal
      fundMe.fund{value: SEND_VALUE}(); 
    }


    uint256 startingOwnerBalance = fundMe.getOwner().balance; 
    uint256 startingFundMeBalance = address(fundMe).balance; 

    //Act
    vm.startPrank(fundMe.getOwner()); 
    fundMe.withdraw(); 
    vm.stopPrank(); 

    // Assert 
    assertEq(address(fundMe).balance, 0); 
    assertEq(
      startingFundMeBalance + startingOwnerBalance, 
      fundMe.getOwner().balance
      ); 
  }

} 
