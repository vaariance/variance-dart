part of '../../variance_dart.dart';

class ModuleInit<T1 extends EthereumAddress, T2 extends Uint8List> {
  final T1 module;
  final T2 initData;

  ModuleInit(this.module, this.initData);
}

class _Safe7579Initializer extends _SafeInitializer {
  final EthereumAddress launchpad;
  final Iterable<ModuleInit>? validators;
  final Iterable<ModuleInit>? executors;
  final Iterable<ModuleInit>? fallbacks;
  final Iterable<ModuleInit>? hooks;
  final Iterable<EthereumAddress>? attesters;
  final int? attestersThreshold;

  _Safe7579Initializer({
    required super.owners,
    required super.threshold,
    required super.module,
    required super.singleton,
    required this.launchpad,
    this.validators,
    this.executors,
    this.fallbacks,
    this.hooks,
    this.attesters,
    this.attestersThreshold,
  });

  Uint8List get7579SetupData() {
    return Contract.encodeFunctionCall(
        "initSafe7579", launchpad, ContractAbis.get("initSafe7579"), [
      module.address,
      executors?.map((e) => [e.module, e.initData]).toList() ?? [],
      fallbacks?.map((e) => [e.module, e.initData]).toList() ?? [],
      hooks?.map((e) => [e.module, e.initData]).toList() ?? [],
      attesters?.toList() ?? [],
      BigInt.from(attestersThreshold ?? 0),
    ]);
  }

  @override
  Uint8List getInitializer() {
    final initData = get7579SetupData();
    final encodedData = abi.encode([
      "address",
      "address[]",
      "uint256",
      "address",
      "bytes",
      "address",
      "(address,bytes)[]"
    ], [
      singleton.address,
      owners.toList(),
      BigInt.from(threshold),
      launchpad,
      initData,
      module.address,
      validators?.map((e) => [e.module, e.initData]).toList() ?? []
    ]);
    final initHash = keccak256(encodedData);
    return Contract.encodeFunctionCall(
        "preValidationSetup",
        launchpad,
        ContractAbis.get("preValidationSetup"),
        [initHash, Constants.zeroAddress, Uint8List(0)]);
  }
}

class _SafeInitializer {
  final Iterable<EthereumAddress> owners;
  final int threshold;
  final Safe4337ModuleAddress module;
  final SafeSingletonAddress singleton;
  final Uint8List Function(Uint8List Function())? encodeWebauthnSetup;

  _SafeInitializer({
    required this.owners,
    required this.threshold,
    required this.module,
    required this.singleton,
    this.encodeWebauthnSetup,
  });

  /// Generates the initializer data for deploying a new Safe contract.
  ///
  /// Returns a [Uint8List] containing the encoded initializer data.
  Uint8List getInitializer() {
    encodeModuleSetup() {
      return Contract.encodeFunctionCall(
          "enableModules", module.setup, ContractAbis.get("enableModules"), [
        [module.address]
      ]);
    }

    final setup = {
      "owners": owners.toList(),
      "threshold": BigInt.from(threshold),
      "to": null,
      "data": null,
      "fallbackHandler": module.address,
    };

    if (encodeWebauthnSetup != null) {
      setup["to"] = Constants.safeMultiSendaddress;
      setup["data"] = encodeWebauthnSetup!(encodeModuleSetup);
    } else {
      setup["to"] = module.setup;
      setup["data"] = encodeModuleSetup();
    }

    return Contract.encodeFunctionCall(
        "setup", singleton.address, ContractAbis.get("setup"), [
      setup["owners"],
      setup["threshold"],
      setup["to"],
      setup["data"],
      setup["fallbackHandler"],
      Constants.zeroAddress,
      BigInt.zero,
      Constants.zeroAddress,
    ]);
  }
}

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

  Uint8List getSafeMultisendCallData(List<EthereumAddress> recipients,
      List<EtherAmount>? amounts, List<Uint8List>? innerCalls,
      [List<Uint8List>? operations]) {
    Uint8List packedCallData = Uint8List(0);

    for (int i = 0; i < recipients.length; i++) {
      Uint8List operation = operations?[i] ?? intToBytes(BigInt.zero);
      Uint8List to = recipients[i].addressBytes;
      Uint8List value = amounts != null
          ? padTo32Bytes(amounts[i].getInWei)
          : padTo32Bytes(BigInt.zero);
      Uint8List dataLength = innerCalls != null
          ? padTo32Bytes(BigInt.from(innerCalls[i].length))
          : padTo32Bytes(BigInt.zero);
      Uint8List data =
          innerCalls != null ? innerCalls[i] : Uint8List.fromList([]);
      packedCallData = packedCallData
          .concat(operation)
          .concat(to)
          .concat(value)
          .concat(dataLength)
          .concat(data);
    }

    return Contract.encodeFunctionCall(
        "multiSend",
        Constants.safeMultiSendaddress,
        ContractAbis.get("multiSend"),
        [packedCallData]);
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

  /// Encodes the signature of a user operation with a validity period.
  ///
  /// [signature] is the signature of the user operation.
  /// [blockInfo] is the current blockInformation including the timestamp and baseFee.
  ///
  /// > Note: The validity period is set to 1 hour.
  /// > Hence varinace_sdk does not generate long-time spaning signatures.
  ///
  /// Returns a HexString representing the encoded signature with a validity period.
  String getSafeSignature(String signature, BlockInformation blockInfo) {
    final timestamp = blockInfo.timestamp.millisecondsSinceEpoch ~/ 1000;
    String validAfter = (timestamp - 3600).toRadixString(16).padLeft(12, '0');
    String validUntil = (timestamp + 3600).toRadixString(16).padLeft(12, '0');

    if (signature.length == 132) {
      int v = int.parse(signature.substring(130, 132), radix: 16);
      if (v >= 27 && v <= 30) {
        v += 4;
      }

      String modifiedV = v.toRadixString(16).padLeft(2, '0');
      return '0x$validAfter$validUntil${signature.substring(2, 130)}$modifiedV';
    } else {
      // passkey signatures - does not contain v
      return '0x$validAfter$validUntil${signature.substring(2)}';
    }
  }

  Uint8List padTo32Bytes(BigInt number) {
    return intToBytes(number).padLeftTo32Bytes();
  }
}
