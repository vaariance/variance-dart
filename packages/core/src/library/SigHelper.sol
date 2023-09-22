// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

enum SigCount {
  ONE,
  TWO
}

struct SigConfig {
  address verifyingSigner1;
  address verifyingSigner2;
  SigCount validNumOfSignatures;
}

error InvalidSignatureLength();

library SignatureValidation {
  // extracts multisig signature
  function extractECDSASignatures(
    bytes memory _fullSignature
  ) public pure returns (bytes memory signature1, bytes memory signature2) {
    signature1 = new bytes(_fullSignature.length / 2);
    signature2 = new bytes(_fullSignature.length / 2);

    // Copying the first signature. Note, that we need an offset of 0x20
    // since it is where the length of the `_fullSignature` is stored
    assembly {
      let r := mload(add(_fullSignature, 0x20))
      let s := mload(add(_fullSignature, 0x40))
      let v := and(mload(add(_fullSignature, 0x41)), 0xff)

      mstore(add(signature1, 0x20), r)
      mstore(add(signature1, 0x40), s)
      mstore8(add(signature1, 0x60), v)
    }

    // Copying the second signature.
    assembly {
      let r := mload(add(_fullSignature, 0x61))
      let s := mload(add(_fullSignature, 0x81))
      let v := and(mload(add(_fullSignature, 0x82)), 0xff)

      mstore(add(signature2, 0x20), r)
      mstore(add(signature2, 0x40), s)
      mstore8(add(signature2, 0x60), v)
    }
  }

  function validateOneSignature(
    bytes calldata _signature,
    bytes32 _hash
  ) public pure returns (address signer) {
    if (total(_signature) != 1) revert InvalidSignatureLength();
    signer = ECDSA.recover(_hash, _signature);
  }

  function validateTwoSignatures(
    bytes calldata _signatures,
    bytes32 _hash
  ) public pure returns (address signer1, address signer2) {
    if (total(_signatures) != 2) revert InvalidSignatureLength();
    (bytes memory signature1, bytes memory signature2) = extractECDSASignatures(_signatures);
    signer1 = ECDSA.recover(_hash, signature1);
    signer2 = ECDSA.recover(_hash, signature2);
  }

  /// gets the total number of signatures passed to paymasterAndData
  /// @return result 0 if sig length is not 64 or 65 or 128 or 130
  function total(bytes calldata signatures) public pure returns (uint256 result) {
    uint256 len = signatures.length;
    assembly {
      switch len
      case 64 {

      }
      case 65 {
        result := 1
      }
      case 128 {

      }
      case 130 {
        result := 2
      }
    }
  }
}
