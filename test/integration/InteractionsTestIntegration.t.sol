// SPDX-License-Identifier: MIT

// fund 
// withdraw 

pragma solidity ^0.8.18;

import { Script, console } from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe } from "../../script/interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Script {
  FundMe fundMe; 

  address USER = makeAddr("user"); 
  uint256 constant SEND_VALUE = 0.1 ether;  
  uint256 constant STARTING_BALANCE = 10 ether;  
  uint256 constant GAS_PRICE = 1; 

  function setUp() external {
    DeployFundMe deploy = new DeployFundMe(); 
    fundMe = deploy.run(); 
    vm.deal(USER, STARTING_BALANCE); 
  }

  function testUserCanFundInteractions() public {

    FundFundMe fundFundMe = new FundFundMe(); 
    fundFundMe.fundFundMe(address(fundMe)); 

    WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); 
    withdrawFundMe.withdrawFundMe(address(fundMe)); 

    assert(address(fundMe).balance == 0); 

  }

}