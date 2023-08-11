// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "./utils/Base64.sol";
import "./interfaces/IPasskeys.sol";
import "./library/Secp256r1.sol";
import "./IDRecovery.sol";

contract PassKeysAccount is IPassKeys, IDRecovery {
    mapping(bytes32 => PassKeyId) private authorisedKeys;
    bytes32[] private knownKeyHashes;

    constructor(string memory _keyId, uint256 _pubKeyX, uint256 _pubKeyY) {
        _addPassKey(keccak256(abi.encodePacked(_keyId)), _pubKeyX, _pubKeyY, _keyId);
    }

    /**
     * Allows the owner to add a passkey key.
     * @param _keyId the id of the key
     * @param _pubKeyX public key X val from a passkey that will have a full ownership and control of this account.
     * @param _pubKeyY public key X val from a passkey that will have a full ownership and control of this account.
     */
    function addPassKey(string memory _keyId, uint256 _pubKeyX, uint256 _pubKeyY) external verified {
        _addPassKey(keccak256(abi.encodePacked(_keyId)), _pubKeyX, _pubKeyY, _keyId);
    }

    function _addPassKey(bytes32 _keyHash, uint256 _pubKeyX, uint256 _pubKeyY, string memory _keyId) internal {
        emit PublicKeyAdded(_keyHash, _pubKeyX, _pubKeyY, _keyId);
        authorisedKeys[_keyHash] = PassKeyId(_pubKeyX, _pubKeyY, _keyId);
        knownKeyHashes.push(_keyHash);
    }

    /// @inheritdoc IPassKeys
    function getAuthorisedKeys() external view override returns (PassKeyId[] memory knownKeys) {
        knownKeys = new PassKeyId[](knownKeyHashes.length);
        for (uint256 i = 0; i < knownKeyHashes.length; i++) {
            knownKeys[i] = authorisedKeys[knownKeyHashes[i]];
        }
        return knownKeys;
    }

    function removePassKey(string calldata _keyId) external verified {
        require(knownKeyHashes.length > 1, "Cannot remove the last key");
        bytes32 keyHash = keccak256(abi.encodePacked(_keyId));
        PassKeyId memory passKey = authorisedKeys[keyHash];
        if (passKey.pubKeyX == 0 && passKey.pubKeyY == 0) {
            return;
        }
        delete authorisedKeys[keyHash];
        for (uint256 i = 0; i < knownKeyHashes.length; i++) {
            if (knownKeyHashes[i] == keyHash) {
                knownKeyHashes[i] = knownKeyHashes[knownKeyHashes.length - 1];
                knownKeyHashes.pop();
                break;
            }
        }
        emit PublicKeyRemoved(keyHash, passKey.pubKeyX, passKey.pubKeyY, passKey.keyId);
    }

    function _validateSignature()
        internal
        virtual
        returns (
            // UserOperation calldata userOp,
            // bytes32 userOpHash
            uint256 validationData
        )
    {
        // (
        //     bytes32 keyHash,
        //     uint256 sigx,
        //     uint256 sigy,
        //     bytes memory authenticatorData,
        //     string memory clientDataJSONPre,
        //     string memory clientDataJSONPost
        // ) = abi.decode(userOp.signature, (bytes32, uint256, uint256, bytes, string, string));

        // string memory opHashBase64 = Base64.encode(bytes.concat(userOpHash));
        // string memory clientDataJSON = string.concat(clientDataJSONPre, opHashBase64, clientDataJSONPost);
        // bytes32 clientHash = sha256(bytes(clientDataJSON));
        // bytes32 sigHash = sha256(bytes.concat(authenticatorData, clientHash));

        // PassKeyId memory passKey = authorisedKeys[keyHash];
        // require(passKey.pubKeyY != 0 && passKey.pubKeyY != 0, "Key not found");
        // require(Secp256r1.Verify(passKey, sigx, sigy, uint256(sigHash)), "Invalid signature");
        return 0;
    }
}
