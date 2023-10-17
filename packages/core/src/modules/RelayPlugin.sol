// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@safe-protocol/contracts/interfaces/Modules.sol";
import "@~/utils/Semver.sol";

// TODO: to complete

contract RelayPlugin is Semver {
  string public constant NAME = "RelayPlugin";

  constructor() Semver(1, 0, 0) {}

  function name() external view returns (string memory) {
    return NAME;
  }

  function version() external view returns (string memory) {
    return _version();
  }

  function metadataProvider() external view returns (uint256 providerType, bytes memory location) {
    //
  }

  function requiresPermissions() external view returns (uint8 permissions) {
    //
  }
}
