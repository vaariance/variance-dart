// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {ByteHasher} from "./library/ByteHasher.sol";
import {IWorldID} from "./interfaces/IWorldID.sol";

contract IDRecover {
    using ByteHasher for bytes;

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();
    error EntropyHasBeenUsed();

    /// @dev The World ID instance that will be used for verifying proofs
    IWorldID internal immutable worldId;

    /// @dev The contract's external nullifier hash
    uint256 internal immutable externalNullifier;

    /// @dev The World ID group ID (always 1)
    uint256 internal immutable groupId = 0;

    uint256 internal nullifierHash;

    mapping(address => bool) usedEntropy;

    /// @param _worldId The WorldID instance that will verify the proofs
    constructor(IWorldID _worldId) {
        worldId = _worldId;
        // Todo: set these parameters
        string memory _appId = "0x";
        string memory _actionId = "0x";
        externalNullifier = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _actionId).hashToField();
    }

    /// initializes the worlID nullifier for the owner of the wallet.
    function initialize(address entropy, uint256 root, uint256 _nullifierHash, uint256[8] memory proof) internal {
        if (nullifierHash != 0) revert InvalidNullifier();

        nullifierHash = _nullifierHash;
        usedEntropy[entropy] = true;

        worldId.verifyProof(
            root,
            groupId,
            ByteHasher.hashToField(abi.encodePacked(entropy)),
            nullifierHash,
            externalNullifier,
            proof
        );
    }

    /// @param entropy An arbitrary input from the user, usually the user's wallet address (check README for further details)
    /// @param root The root of the Merkle tree (returned by the JS widget).
    /// @param _nullifierHash The nullifier hash for this proof, preventing double signaling (returned by the JS widget).
    /// @param proof The zero-knowledge proof that demonstrates the claimer is registered with World ID (returned by the JS widget).
    /// @dev Feel free to rename this method however you want! We've used `claim`, `verify` or `execute` in the past.
    function verifyAndContinue(
        address entropy,
        uint256 root,
        uint256 _nullifierHash,
        uint256[8] calldata proof
    ) public {
        // First, we make sure this person is unique
        require(nullifierHash != 0, "Not initialized");

        if (usedEntropy[entropy]) revert EntropyHasBeenUsed();
        if (_nullifierHash != nullifierHash) revert InvalidNullifier();
        usedEntropy[entropy] = true;

        // We now verify the provided proof is valid and the user is verified by World ID
        worldId.verifyProof(
            root,
            groupId,
            abi.encodePacked(entropy).hashToField(),
            nullifierHash,
            externalNullifier,
            proof
        );
    }
}
