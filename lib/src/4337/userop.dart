part of '../../variance.dart';

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
  @Deprecated("now packed in accountGasLimits from v0.7")
  final BigInt callGasLimit;

  @override
  @Deprecated("now packed in accountGasLimits from v0.7")
  final BigInt verificationGasLimit;

  @override
  final Uint8List accountGasLimits;

  @override
  final BigInt preVerificationGas;

  @override
  @Deprecated("now packed in gasFees from v0.7")
  BigInt maxFeePerGas;

  @override
  @Deprecated("now packed in gasFees from v0.7")
  BigInt maxPriorityFeePerGas;

  @override
  final Uint8List gasFees;

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
    required this.accountGasLimits,
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.gasFees,
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
      callGasLimit: map['callGasLimit'] != null
          ? BigInt.parse(map['callGasLimit'] as String)
          : BigInt.zero,
      verificationGasLimit: map['verificationGasLimit'] != null
          ? BigInt.parse(map['verificationGasLimit'] as String)
          : BigInt.zero,
      accountGasLimits: map['accountGasLimits'] != null
          ? hexToBytes(map['accountGasLimits'] as String)
          : Uint8List(0),
      preVerificationGas: BigInt.parse(map['preVerificationGas'] as String),
      maxFeePerGas: map['maxFeePerGas'] != null
          ? BigInt.parse(map['maxFeePerGas'] as String)
          : BigInt.zero,
      maxPriorityFeePerGas: map['maxPriorityFeePerGas'] != null
          ? BigInt.parse(map['maxPriorityFeePerGas'] as String)
          : BigInt.zero,
      gasFees: map['gasFees'] != null
          ? hexToBytes(map['gasFees'] as String)
          : Uint8List(0),
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
  factory UserOperation.partial(
          {required Uint8List callData,
          EthereumAddress? sender,
          BigInt? nonce,
          Uint8List? initCode,
          BigInt? callGasLimit,
          BigInt? verificationGasLimit,
          Uint8List? accountGasLimits,
          BigInt? preVerificationGas,
          BigInt? maxFeePerGas,
          BigInt? maxPriorityFeePerGas,
          Uint8List? gasFees}) =>
      UserOperation(
        sender: sender ?? Constants.zeroAddress,
        nonce: nonce ?? BigInt.zero,
        initCode: initCode ?? Uint8List(0),
        callData: callData,
        callGasLimit: callGasLimit ?? BigInt.from(250000),
        verificationGasLimit: verificationGasLimit ?? BigInt.from(750000),
        preVerificationGas: preVerificationGas ?? BigInt.from(51000),
        accountGasLimits: accountGasLimits ?? Uint8List(0),
        maxFeePerGas: maxFeePerGas ?? BigInt.one,
        maxPriorityFeePerGas: maxPriorityFeePerGas ?? BigInt.one,
        gasFees: gasFees ?? Uint8List(0),
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
    Uint8List? accountGasLimits,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    Uint8List? gasFees,
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
      accountGasLimits: accountGasLimits ?? this.accountGasLimits,
      preVerificationGas: preVerificationGas ?? this.preVerificationGas,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
      gasFees: gasFees ?? this.gasFees,
      signature: signature ?? this.signature,
      paymasterAndData: paymasterAndData ?? this.paymasterAndData,
    );
  }

  @override
  Uint8List hash(Chain chain) {
    Uint8List encoded;
    if (chain.entrypoint == EntryPoint.v07) {
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
        accountGasLimits,
        preVerificationGas,
        gasFees,
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
  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  Map<String, String> toMap() {
    Map<String, String> op = {
      'sender': sender.hexEip55,
      'nonce': '0x${nonce.toRadixString(16)}',
      'initCode': hexlify(initCode),
      'callData': hexlify(callData),
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'signature': signature,
      'paymasterAndData': hexlify(paymasterAndData),
    };
    if (accountGasLimits.isEmpty || accountGasLimits == Uint8List(0)) {
      op['verificationGasLimit'] =
          '0x${verificationGasLimit.toRadixString(16)}';
      op['preVerificationGas'] = '0x${preVerificationGas.toRadixString(16)}';
    } else {
      op['accountGasLimits'] = hexlify(accountGasLimits);
    }

    if (gasFees.isEmpty || gasFees == Uint8List(0)) {
      op['maxFeePerGas'] = '0x${maxFeePerGas.toRadixString(16)}';
      op['maxPriorityFeePerGas'] =
          '0x${maxPriorityFeePerGas.toRadixString(16)}';
    } else {
      op['gasFees'] = hexlify(gasFees);
    }

    return op;
  }

  @override
  UserOperation updateOpGas(
      UserOperationGas? opGas, Map<String, dynamic>? feePerGas) {
    return copyWith(
        callGasLimit: opGas?.callGasLimit,
        verificationGasLimit: opGas?.verificationGasLimit,
        accountGasLimits: opGas?.accountGasLimits,
        preVerificationGas: opGas?.preVerificationGas,
        maxFeePerGas: (feePerGas?["maxFeePerGas"] as EtherAmount?)?.getInWei,
        maxPriorityFeePerGas:
            (feePerGas?["maxPriorityFeePerGas"] as EtherAmount?)?.getInWei,
        gasFees: feePerGas?["gasFees"] as Uint8List?);
  }

  Future<void> validate(bool deployed, [String? initCode]) async {
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
  final Uint8List accountGasLimits;
  final BigInt preVerificationGas;
  BigInt? validAfter;
  BigInt? validUntil;
  UserOperationGas({
    required this.callGasLimit,
    required this.verificationGasLimit,
    required this.accountGasLimits,
    required this.preVerificationGas,
    this.validAfter,
    this.validUntil,
  });
  factory UserOperationGas.fromMap(Map<String, dynamic> map) {
    return UserOperationGas(
      callGasLimit: map['callGasLimit'] != null
          ? BigInt.parse(map['callGasLimit'])
          : BigInt.zero,
      verificationGasLimit: map['callGasLimit'] != null
          ? BigInt.parse(map['verificationGasLimit'])
          : BigInt.zero,
      accountGasLimits: map['accountGasLimits'] != null
          ? hexToBytes(map['accountGasLimits'])
          : Uint8List(0),
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
  );

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
    );
  }
}

class UserOperationResponse {
  final String userOpHash;

  UserOperationResponse(this.userOpHash);
}
