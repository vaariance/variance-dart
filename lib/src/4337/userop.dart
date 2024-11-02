part of '../../variance_dart.dart';

/// A class that implements the user operation struct defined in EIP4337.
class UserOperation implements UserOperationBase {
  @override
  final EthereumAddress sender;

  @override
  final BigInt nonce;

  @override
  final Uint8List initCode;

  @override
  final Uint8List callData;

  @override
  final BigInt callGasLimit;

  @override
  final BigInt verificationGasLimit;

  @override
  final BigInt preVerificationGas;

  @override
  BigInt maxFeePerGas;

  @override
  BigInt maxPriorityFeePerGas;

  @override
  String signature;

  @override
  Uint8List paymasterAndData;

  UserOperation({
    required this.sender,
    required this.nonce,
    required this.initCode,
    required this.callData,
    required this.callGasLimit,
    required this.verificationGasLimit,
    required this.preVerificationGas,
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.signature,
    required this.paymasterAndData,
  });

  factory UserOperation.fromJson(String source) =>
      UserOperation.fromMap(json.decode(source) as Map<String, String>);

  factory UserOperation.fromMap(Map<String, String> map) {
    return UserOperation(
      sender: EthereumAddress.fromHex(map['sender'] as String),
      nonce: BigInt.parse(map['nonce'] as String),
      initCode: hexToBytes(map['initCode'] as String),
      callData: hexToBytes(map['callData'] as String),
      callGasLimit: BigInt.parse(map['callGasLimit'] as String),
      verificationGasLimit: BigInt.parse(map['verificationGasLimit'] as String),
      preVerificationGas: BigInt.parse(map['preVerificationGas'] as String),
      maxFeePerGas: BigInt.parse(map['maxFeePerGas'] as String),
      maxPriorityFeePerGas: BigInt.parse(map['maxPriorityFeePerGas'] as String),
      signature: map['signature'] as String,
      paymasterAndData: hexToBytes(map['paymasterAndData'] as String),
    );
  }

  /// Creates a partial [UserOperation] with specified parameters.
  ///
  /// Parameters:
  ///   - `callData` (required): The call data as a [Uint8List].
  ///   - `sender`: The Ethereum address of the sender. Defaults to the smartwallet address.
  ///   - `nonce`: The nonce value. Defaults to [BigInt.zero].
  ///   - `initCode`: The initialization code as a [Uint8List]. Defaults to an empty [Uint8List].
  ///   - `callGasLimit`: The call gas limit as a [BigInt]. Defaults to [BigInt.from(250000)].
  ///   - `verificationGasLimit`: The verification gas limit as a [BigInt]. Defaults to [BigInt.from(750000)].
  ///   - `preVerificationGas`: The pre-verification gas as a [BigInt]. Defaults to [BigInt.from(51000)].
  ///   - `maxFeePerGas`: The maximum fee per gas as a [BigInt]. Defaults to [BigInt.one].
  ///   - `maxPriorityFeePerGas`: The maximum priority fee per gas as a [BigInt]. Defaults to [BigInt.one].
  ///
  /// Returns:
  ///   A [UserOperation] instance.
  ///
  /// Example:
  /// ```dart
  /// var partialUserOperation = UserOperation.partial(
  ///   callData: Uint8List(0xabcdef),
  ///   // Other parameters can be set as needed.
  /// );
  /// ```
  factory UserOperation.partial({
    required Uint8List callData,
    EthereumAddress? sender,
    BigInt? nonce,
    Uint8List? initCode,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) =>
      UserOperation(
        sender: sender ?? Constants.zeroAddress,
        nonce: nonce ?? BigInt.zero,
        initCode: initCode ?? Uint8List(0),
        callData: callData,
        callGasLimit: callGasLimit ?? BigInt.from(250000),
        verificationGasLimit: verificationGasLimit ?? BigInt.from(750000),
        preVerificationGas: preVerificationGas ?? BigInt.from(51000),
        maxFeePerGas: maxFeePerGas ?? BigInt.one,
        maxPriorityFeePerGas: maxPriorityFeePerGas ?? BigInt.one,
        signature: "0x",
        paymasterAndData: Uint8List(0),
      );

  UserOperation copyWith({
    EthereumAddress? sender,
    BigInt? nonce,
    Uint8List? initCode,
    Uint8List? callData,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    String? signature,
    Uint8List? paymasterAndData,
  }) {
    return UserOperation(
      sender: sender ?? this.sender,
      nonce: nonce ?? this.nonce,
      initCode: initCode ?? this.initCode,
      callData: callData ?? this.callData,
      callGasLimit: callGasLimit ?? this.callGasLimit,
      verificationGasLimit: verificationGasLimit ?? this.verificationGasLimit,
      preVerificationGas: preVerificationGas ?? this.preVerificationGas,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
      signature: signature ?? this.signature,
      paymasterAndData: paymasterAndData ?? this.paymasterAndData,
    );
  }

  @override
  Uint8List hash(Chain chain) {
    Uint8List encoded;
    if (chain.entrypoint.version == EntryPointAddress.v07.version) {
      encoded = keccak256(abi.encode([
        'address',
        'uint256',
        'bytes32',
        'bytes32',
        'bytes32',
        'uint256',
        'bytes32',
        'bytes32',
      ], [
        sender,
        nonce,
        keccak256(initCode),
        keccak256(callData),
        packUints(verificationGasLimit, callGasLimit),
        preVerificationGas,
        packUints(maxPriorityFeePerGas, maxFeePerGas),
        keccak256(paymasterAndData),
      ]));
    } else {
      encoded = keccak256(abi.encode([
        'address',
        'uint256',
        'bytes32',
        'bytes32',
        'uint256',
        'uint256',
        'uint256',
        'uint256',
        'uint256',
        'bytes32',
      ], [
        sender,
        nonce,
        keccak256(initCode),
        keccak256(callData),
        callGasLimit,
        verificationGasLimit,
        preVerificationGas,
        maxFeePerGas,
        maxPriorityFeePerGas,
        keccak256(paymasterAndData),
      ]));
    }
    return keccak256(abi.encode(['bytes32', 'address', 'uint256'],
        [encoded, chain.entrypoint.address, BigInt.from(chain.chainId)]));
  }

  @override
  Map<String, String> packUserOperation() {
    Map<String, String> op = {
      'sender': sender.hexEip55,
      'nonce': '0x${nonce.toRadixString(16)}',
      'callData': hexlify(callData),
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'verificationGasLimit': '0x${verificationGasLimit.toRadixString(16)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      'maxFeePerGas': '0x${maxFeePerGas.toRadixString(16)}',
      'maxPriorityFeePerGas': '0x${maxPriorityFeePerGas.toRadixString(16)}',
      'signature': signature,
    };
    if (initCode.isNotEmpty) {
      op['factory'] = hexlify(initCode.sublist(0, 20));
      op['factoryData'] = hexlify(initCode.sublist(20));
    }
    if (paymasterAndData.isNotEmpty) {
      op['paymaster'] = hexlify(paymasterAndData.sublist(0, 20));
      final upackedPaymasterGasFields =
          unpackUints(hexlify(paymasterAndData.sublist(20, 52)));
      op['paymasterVerificationGasLimit'] =
          '0x${upackedPaymasterGasFields[0].toRadixString(16)}';
      op['paymasterPostOpGasLimit'] =
          '0x${upackedPaymasterGasFields[1].toRadixString(16)}';
      op['paymasterData'] = hexlify(paymasterAndData.sublist(52));
    }
    return op;
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  Map<String, String> toMap([double version = 0.6]) {
    if (version == 0.7) return packUserOperation();
    return {
      'sender': sender.hexEip55,
      'nonce': '0x${nonce.toRadixString(16)}',
      'initCode': hexlify(initCode),
      'callData': hexlify(callData),
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'verificationGasLimit': '0x${verificationGasLimit.toRadixString(16)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      'maxFeePerGas': '0x${maxFeePerGas.toRadixString(16)}',
      'maxPriorityFeePerGas': '0x${maxPriorityFeePerGas.toRadixString(16)}',
      'paymasterAndData': hexlify(paymasterAndData),
      'signature': signature,
    };
  }

  @override
  UserOperation updateOpGas([UserOperationGas? opGas, Fee? fee]) {
    return copyWith(
      callGasLimit: opGas?.callGasLimit,
      verificationGasLimit: opGas?.verificationGasLimit,
      preVerificationGas: opGas?.preVerificationGas,
      maxFeePerGas: fee?.maxFeePerGas,
      maxPriorityFeePerGas: fee?.maxPriorityFeePerGas,
    );
  }

  @override
  void validate(bool deployed, [String? initCode]) {
    require(
        deployed
            ? hexlify(this.initCode).toLowerCase() == "0x"
            : hexlify(this.initCode).toLowerCase() == initCode?.toLowerCase(),
        "InitCode mismatch");
    require(callData.length >= 4, "Calldata too short");
    require(signature.length >= 64, "Signature too short");
  }
}

class UserOperationByHash {
  UserOperation userOperation;
  final String entryPoint;
  final BigInt blockNumber;
  final BigInt blockHash;
  final BigInt transactionHash;
  UserOperationByHash(
    this.userOperation,
    this.entryPoint,
    this.blockNumber,
    this.blockHash,
    this.transactionHash,
  );

  factory UserOperationByHash.fromMap(Map<String, dynamic> map) {
    return UserOperationByHash(
      UserOperation.fromMap(map['userOperation']),
      map['entryPoint'],
      BigInt.parse(map['blockNumber']),
      BigInt.parse(map['blockHash']),
      BigInt.parse(map['transactionHash']),
    );
  }
}

class UserOperationGas {
  final BigInt callGasLimit;
  final BigInt verificationGasLimit;
  final BigInt preVerificationGas;
  BigInt? validAfter;
  BigInt? validUntil;
  UserOperationGas({
    required this.callGasLimit,
    required this.verificationGasLimit,
    required this.preVerificationGas,
    this.validAfter,
    this.validUntil,
  });
  factory UserOperationGas.fromMap(Map<String, dynamic> map) {
    final List<BigInt> accountGasLimits = map['accountGasLimits'] != null
        ? unpackUints(map['accountGasLimits'])
        : [
            BigInt.parse(map['verificationGasLimit']),
            BigInt.parse(map['callGasLimit'])
          ];

    return UserOperationGas(
      verificationGasLimit: accountGasLimits[0],
      callGasLimit: accountGasLimits[1],
      preVerificationGas: BigInt.parse(map['preVerificationGas']),
      validAfter:
          map['validAfter'] != null ? BigInt.parse(map['validAfter']) : null,
      validUntil:
          map['validUntil'] != null ? BigInt.parse(map['validUntil']) : null,
    );
  }
}

class UserOperationReceipt {
  final String userOpHash;
  String? entrypoint;
  final String sender;
  final BigInt nonce;
  String? paymaster;
  final BigInt actualGasCost;
  final BigInt actualGasUsed;
  final bool success;
  String? reason;
  final List logs;
  final TransactionReceipt txReceipt;

  UserOperationReceipt(
      this.userOpHash,
      this.entrypoint,
      this.sender,
      this.nonce,
      this.paymaster,
      this.actualGasCost,
      this.actualGasUsed,
      this.success,
      this.reason,
      this.logs,
      this.txReceipt);

  factory UserOperationReceipt.fromMap(Map<String, dynamic> map) {
    return UserOperationReceipt(
      map['userOpHash'],
      map['entrypoint'],
      map['sender'],
      BigInt.parse(map['nonce']),
      map['paymaster'],
      BigInt.parse(map['actualGasCost']),
      BigInt.parse(map['actualGasUsed']),
      map['success'],
      map['reason'],
      List.castFrom(map['logs']),
      TransactionReceipt.fromMap(map['txReceipt']),
    );
  }
}

class UserOperationResponse {
  final String userOpHash;
  final Future<UserOperationReceipt?> Function(String) _callback;

  UserOperationResponse(this.userOpHash, this._callback);

  Future<UserOperationReceipt?> wait(
      [Duration timeout = const Duration(seconds: 15),
      Duration pollInterval = const Duration(seconds: 2)]) async {
    assert(
        timeout.inSeconds > 0,
        RangeError.value(
            timeout.inSeconds, "timeout", "wait timeout must be >= 0 sec"));
    assert(
        pollInterval.inSeconds > 0,
        RangeError.value(pollInterval.inSeconds, "pollInterval",
            "pollInterval must be >= 0 sec"));
    assert(
        pollInterval < timeout,
        RangeError.value(
            timeout.inSeconds, "timeout", "timeout must be > pollInterval"));

    Duration count = Duration.zero;

    while (count < timeout) {
      await Future.delayed(pollInterval);

      try {
        final receipt = await _callback(userOpHash);
        if (receipt != null) {
          return receipt;
        }
        count += pollInterval;
      } catch (e) {
        count += pollInterval;
      }
    }

    throw TimeoutException(
        "can't find useroperation with hash $userOpHash", timeout);
  }
}

class TransactionReceipt {
  final String transactionHash;
  final String transactionIndex;
  final String blockHash;
  final String blockNumber;
  final String from;
  final String to;
  final String cumulativeGasUsed;
  final String gasUsed;
  final String? contractAddress;
  final List logs;
  final String? logsBloom;
  final String status;
  final String effectiveGasPrice;

  TransactionReceipt(
    this.transactionHash,
    this.transactionIndex,
    this.blockHash,
    this.blockNumber,
    this.from,
    this.to,
    this.cumulativeGasUsed,
    this.gasUsed,
    this.contractAddress,
    this.logs,
    this.logsBloom,
    this.status,
    this.effectiveGasPrice,
  );

  factory TransactionReceipt.fromMap(Map<String, dynamic> map) {
    return TransactionReceipt(
      map['transactionHash'],
      map['transactionIndex'],
      map['blockHash'],
      map['blockNumber'],
      map['from'],
      map['to'],
      map['cumulativeGasUsed'],
      map['gasUsed'],
      map['contractAddress'],
      List.castFrom(map['logs']),
      map['logsBloom'],
      map['status'],
      map['effectiveGasPrice'],
    );
  }
}
