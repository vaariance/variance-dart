part of '../../variance_dart.dart';

/// A class that extends the Safe4337Module and implements the Safe4337ModuleBase interface.
/// It provides functionality related to Safe accounts and user operations on an Ethereum-like blockchain.
class _SafePlugin extends Safe4337Module implements Safe4337ModuleBase {
  /// Creates a new instance of the _SafePlugin class.
  ///
  /// [address] is the address of the Safe 4337 module.
  /// [chainId] is the ID of the blockchain chain.
  /// [client] is the client used for interacting with the blockchain.
  _SafePlugin({
    required super.address,
    super.chainId,
    required super.client,
  });

  /// Encodes the signature of a user operation with a validity period.
  ///
  /// [signature] is the signature of the user operation.
  /// [blockInfo] is the current blockInformation including the timestamp and baseFee.
  ///
  /// Returns a HexString representing the encoded signature with a validity period.
  String getSafeSignature<T>(T signature, BlockInformation blockInfo) {
    late Uint8List signatureBytes;

    if (signature is Uint8List) {
      signatureBytes = signature;
    } else if (signature is String && signature.startsWith('0x')) {
      signatureBytes = hexToBytes(signature);
    } else {
      throw ArgumentError('Unsupported signature type');
    }
    final timestamp = blockInfo.timestamp.millisecondsSinceEpoch ~/ 1000;

    String validAfter = (timestamp - 3600).toRadixString(16).padLeft(12, '0');
    String validUntil = (timestamp + 3600).toRadixString(16).padLeft(12, '0');

    int v = signatureBytes[64];
    if (v >= 27 && v <= 30) {
      v += 4;
    }

    String modifiedV = v.toRadixString(16).padLeft(2, '0');
    String hexSignature = hexlify(signatureBytes.sublist(0, 64));
    return '0x$validAfter$validUntil$hexSignature$modifiedV';
  }

  /// Computes the hash of a Safe UserOperation.
  ///
  /// [op] is an object representing the user operation details.
  /// [blockInfo] is the current timestamp in seconds.
  ///
  /// Returns a Future that resolves to the hash of the user operation as a Uint8List.
  Future<Uint8List> getSafeOperationHash(
      UserOperation op, BlockInformation blockInfo) async {
    if (self.address == Safe4337ModuleAddress.v07.address) {
      return getOperationHash$2((
        userOp: [
          op.sender,
          op.nonce,
          op.initCode,
          op.callData,
          packUints(op.verificationGasLimit, op.callGasLimit),
          op.preVerificationGas,
          packUints(op.maxPriorityFeePerGas, op.maxFeePerGas),
          op.paymasterAndData,
          hexToBytes(getSafeSignature(op.signature, blockInfo))
        ]
      ));
    }
    return getOperationHash((
      userOp: [
        op.sender,
        op.nonce,
        op.initCode,
        op.callData,
        op.callGasLimit,
        op.verificationGasLimit,
        op.preVerificationGas,
        op.maxFeePerGas,
        op.maxPriorityFeePerGas,
        op.paymasterAndData,
        hexToBytes(getSafeSignature(op.signature, blockInfo))
      ]
    ));
  }

  Uint8List getSafeMultisendCallData(List<EthereumAddress> recipients,
      List<EtherAmount>? amounts, List<Uint8List>? innerCalls) {
    Uint8List packedCallData = Uint8List(0);

    for (int i = 0; i < recipients.length; i++) {
      Uint8List operation = Uint8List.fromList([0]);
      Uint8List to = recipients[i].addressBytes;
      Uint8List value = amounts != null
          ? padTo32Bytes(amounts[i].getInWei)
          : padTo32Bytes(BigInt.zero);
      Uint8List dataLength = innerCalls != null
          ? padTo32Bytes(BigInt.from(innerCalls[i].length))
          : padTo32Bytes(BigInt.zero);
      Uint8List data =
          innerCalls != null ? innerCalls[i] : Uint8List.fromList([]);
      Uint8List encodedCall = Uint8List.fromList(
          [...operation, ...to, ...value, ...dataLength, ...data]);
      packedCallData = Uint8List.fromList([...packedCallData, ...encodedCall]);
    }

    return Contract.encodeFunctionCall(
        "multiSend",
        Constants.safeMultiSendaddress,
        ContractAbis.get("multiSend"),
        [packedCallData]);
  }

  Uint8List padTo32Bytes(BigInt number) {
    final bytes = intToBytes(number);
    return bytes.length < 32
        ? Uint8List.fromList([...Uint8List(32 - bytes.length), ...bytes])
        : bytes;
  }
}
