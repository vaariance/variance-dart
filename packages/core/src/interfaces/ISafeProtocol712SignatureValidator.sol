// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

bytes4 constant VALIDATION_SUCCESS_MAGIC = 0x1626ba7e;

interface ISafeProtocol712SignatureValidator {
  /**
   * @param safe The Safe that has delegated the signature verification
   * @param sender The address that originally called the Safe's `isValidSignature` method
   * @param _hash The EIP-712 hash whose signature will be verified
   * @param domainSeparator The EIP-712 domainSeparator
   * @param typeHash The EIP-712 typeHash
   * @param encodeData The EIP-712 encoded data
   * @param payload An arbitrary payload that can be used to pass additional data to the validator
   * @return magic The magic value that should be returned if the signature is valid (0x1626ba7e)
   */
  function isValidSignature(
    address safe,
    address sender,
    bytes32 _hash,
    bytes32 domainSeparator,
    bytes32 typeHash,
    bytes calldata encodeData,
    bytes calldata payload
  ) external view returns (bytes4 magic);
}
