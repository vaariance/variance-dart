// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AccountsFactory.sol";
import "../test/Config.sol";

contract DeployAccountsFactory is Script {
  Config.NetworkConfig config;

  function setUp() public {
    Config conf = new Config();
    config = conf.getActiveNetworkConfig();
  }

  function run() external {
    vm.startBroadcast();
    new AccountsFactory{salt: bytes32(0)}(IEntryPoint(config.entrypoint));
    vm.stopBroadcast();
  }
}
