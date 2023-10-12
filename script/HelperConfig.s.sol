// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script { 
  NetworkConfig public activeNetworkConfig;

  struct NetworkConfig {
    address priceFeed; // ETH/USD
  }

// if more networks, insert here. 
  constructor() { 
    if (block.chainid == 11155111){
      activeNetworkConfig = getSepoliaEthConfig(); 
    } else {
      activeNetworkConfig = getAnvilEthConfig(); 
    }
  }


  // this function can be copied to any network! 
  function getSepoliaEthConfig() public pure returns (NetworkConfig memory) { 
    // price feed address
    NetworkConfig memory sepoliaConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
  }

  function getAnvilEthConfig() public returns (NetworkConfig memory) { 

    vm.startBroadcast(); 
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
    vm.stopBroadcast(); 

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPriceFeed)
    });

    return anvilConfig; 
  }

}