// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import "@~/interfaces/ISafeProtocol712SignatureValidator.sol";

// NOTE:: PLEASE NOTE:: this is just a trial
// Does not in any way relate with the SAFE PROTOCOL SPEC
// THE SAFE PROTOCOL SPEC is still in progress

contract Safe712SignatureValidator is ISafeProtocol712SignatureValidator {
  function isValidSignature(
    address safe,
    address sender,
    bytes32 _hash,
    bytes32 domainSeparator,
    bytes32 typeHash,
    bytes calldata encodeData,
    bytes calldata payload
  ) external view returns (bytes4 magic) {}
}
