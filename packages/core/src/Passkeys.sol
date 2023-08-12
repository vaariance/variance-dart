// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "./utils/Base64.sol";
import "./interfaces/IPasskeys.sol";
import "./library/Secp256r1.sol";
import "./IDRecover.sol";
import "./library/SafeStorage.sol";
import "./interfaces/ISafe.sol";

/// NOTE::::: PLEASE NOTE
/// the idea is to have the user use their world Id to recover their safe.
/// i was unable to test the recovery process because,
/// i was unable to get access to worldcoin dev portal
/// hence the initialize and verifyAndContinue steps are commented out.
contract PassKeysAccount is SafeStorage, IPassKeys, IDRecover {
    address public immutable self;
    address public immutable entryPoint;

    address internal constant SENTINEL_MODULES = address(0x1);

    // other storages
    mapping(bytes32 => PassKeyId) private authorisedKeys;
    bytes32[] private knownKeyHashes;

    constructor(
        address _entrypoint,
        IWorldID _worldId,
        address entropy,
        uint256 root,
        uint256 _nullifierHash,
        uint256[8] memory proof
    ) IDRecover(_worldId) {
        entryPoint = _entrypoint;
        self = address(this);
        // initialize the safe with worldId
        // Todo: get access to worldcoin dev portal
        // initialize(entropy, root, _nullifierHash, proof);
    }

    /**
     * Allows the owner to add a passkey key.
     * @param _keyId the id of the key
     * @param _pubKeyX public key X val from a passkey that will have a full ownership and control of this account.
     * @param _pubKeyY public key X val from a passkey that will have a full ownership and control of this account.
     */
    function addPassKey(
        string memory _keyId,
        uint256 _pubKeyX,
        uint256 _pubKeyY,
        address entropy,
        uint256 root,
        uint256 _nullifierHash,
        uint256[8] calldata proof
    ) external {
        // Todo: get access to worldcoin dev portal
        // verifyAndContinue(entropy, root, _nullifierHash, proof);
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

    function removePassKey(
        string calldata _keyId,
        address entropy,
        uint256 root,
        uint256 _nullifierHash,
        uint256[8] calldata proof
    ) external {
        // Todo: get access to worldcoin dev portal
        // verifyAndContinue(entropy, root, _nullifierHash, proof);
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

    function enableMyself() public {
        require(self != address(this), "You need to DELEGATECALL");

        // Module cannot be added twice.
        require(modules[self] == address(0), "GS102");
        modules[self] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = self;
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData) {
        _beforeExecTransaction(userOp, userOpHash);

        address payable safeAddress = payable(userOp.sender);
        ISafe senderSafe = ISafe(safeAddress);

        if (missingAccountFunds != 0) {
            senderSafe.execTransactionFromModule(entryPoint, missingAccountFunds, "", 0);
        }
        return 0;
    }

    function execTransaction(address to, uint256 value, bytes calldata data) external payable {
        address payable safeAddress = payable(msg.sender);
        ISafe safe = ISafe(safeAddress);
        require(safe.execTransactionFromModule(to, value, data, 0), "tx failed");
    }

    function _beforeExecTransaction(UserOperation calldata userOp, bytes32 userOpHash) internal view {
        (
            bytes32 keyHash,
            uint256 sigx,
            uint256 sigy,
            bytes memory authenticatorData,
            string memory clientDataJSONPre,
            string memory clientDataJSONPost
        ) = abi.decode(userOp.signature, (bytes32, uint256, uint256, bytes, string, string));

        string memory opHashBase64 = Base64.encode(bytes.concat(userOpHash));
        string memory clientDataJSON = string.concat(clientDataJSONPre, opHashBase64, clientDataJSONPost);
        bytes32 clientHash = sha256(bytes(clientDataJSON));
        bytes32 sigHash = sha256(bytes.concat(authenticatorData, clientHash));

        PassKeyId memory passKey = authorisedKeys[keyHash];
        require(passKey.pubKeyY != 0 && passKey.pubKeyY != 0, "Key not found");
        require(Secp256r1.Verify(passKey, sigx, sigy, uint256(sigHash)), "Invalid signature");
    }
}
