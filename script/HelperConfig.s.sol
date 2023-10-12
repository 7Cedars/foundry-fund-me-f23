// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig { 

  struct NetworkConfig {
    address priceFeed; // ETH/USD
  }
  
  function getSepoliaEthConfig() public pure returns (NetworkConfig memory) { 
    // price feed address
    NetworkConfig memory sepoliaConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
  }

  function getAnvilEthConfig() public pure returns (NetworkConfig memory) { 
    
  }

}