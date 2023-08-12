// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "../library/Secp256r1.sol";

/**
 * a PassKey account should expose its own public key.
 */
interface IPassKeys {
    event PublicKeyAdded(bytes32 indexed keyHash, uint256 pubKeyX, uint256 pubKeyY, string keyId);
    event PublicKeyRemoved(bytes32 indexed keyHash, uint256 pubKeyX, uint256 pubKeyY, string keyId);

    /**
     * @return knows passkey ids on this wallet.
     */
    function getAuthorisedKeys() external view returns (PassKeyId[] memory);

    /**
     * Allows the owner to add a passkey key.
     * @param _keyId the id of the key
     * @param _pubKeyX public key X val from a passkey that will have a full ownership and control of this account.
     * @param _pubKeyY public key X val from a passkey that will have a full ownership and control of this account.
     */
    function addPassKey(
        string calldata _keyId,
        uint256 _pubKeyX,
        uint256 _pubKeyY,
        address entropy,
        uint256 root,
        uint256 _nullifierHash,
        uint256[8] calldata proof
    ) external;

    /**
     * Allows the owner to remove a passkey key.
     * @param _keyId the id of the key to be removed
     */
    function removePassKey(
        string calldata _keyId,
        address entropy,
        uint256 root,
        uint256 _nullifierHash,
        uint256[8] calldata proof
    ) external;
}
