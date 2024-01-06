part of 'package:variance_dart/variance.dart';

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
        callGasLimit: callGasLimit ?? BigInt.from(10000000),
        verificationGasLimit: verificationGasLimit ?? BigInt.from(10000000),
        preVerificationGas: preVerificationGas ?? BigInt.from(21000),
        maxFeePerGas: maxFeePerGas ?? BigInt.one,
        maxPriorityFeePerGas: maxPriorityFeePerGas ?? BigInt.one,
        signature: "0x",
        paymasterAndData: Uint8List(0),
      );

  factory UserOperation.update(
    Map<String, String> map, {
    UserOperationGas? opGas,
    EthereumAddress? sender,
    BigInt? nonce,
    String? initCode,
  }) {
    if (opGas != null) {
      map['callGasLimit'] = '0x${opGas.callGasLimit.toRadixString(16)}';
      map['verificationGasLimit'] =
          '0x${opGas.verificationGasLimit.toRadixString(16)}';
      map['preVerificationGas'] =
          '0x${(opGas.preVerificationGas + BigInt.from(35000)).toRadixString(16)}';
    }

    if (sender != null) map['sender'] = sender.hex;
    if (nonce != null) map['nonce'] = '0x${nonce.toRadixString(16)}';
    if (initCode != null) map['initCode'] = initCode;

    return UserOperation.fromMap(map);
  }

  @override
  Uint8List hash(Chain chain) {
    final encoded = keccak256(abi.encode([
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
    return keccak256(abi.encode(['bytes32', 'address', 'uint256'],
        [encoded, chain.entrypoint, BigInt.from(chain.chainId)]));
  }

  @override
  Map<String, String> toMap() {
    return <String, String>{
      'sender': sender.hexEip55,
      'nonce': '0x${nonce.toRadixString(16)}',
      'initCode': hexlify(initCode),
      'callData': hexlify(callData),
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'verificationGasLimit': '0x${verificationGasLimit.toRadixString(16)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      'maxFeePerGas': '0x${maxFeePerGas.toRadixString(16)}',
      'maxPriorityFeePerGas': '0x${maxPriorityFeePerGas.toRadixString(16)}',
      'signature': signature,
      'paymasterAndData': hexlify(paymasterAndData),
    };
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
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
  final BigInt preVerificationGas;
  final BigInt verificationGasLimit;
  BigInt? validAfter;
  BigInt? validUntil;
  final BigInt callGasLimit;
  UserOperationGas({
    required this.preVerificationGas,
    required this.verificationGasLimit,
    this.validAfter,
    this.validUntil,
    required this.callGasLimit,
  });
  factory UserOperationGas.fromMap(Map<String, dynamic> map) {
    return UserOperationGas(
      preVerificationGas: BigInt.parse(map['preVerificationGas']),
      verificationGasLimit: BigInt.parse(map['verificationGasLimit']),
      validAfter:
          map['validAfter'] != null ? BigInt.parse(map['validAfter']) : null,
      validUntil:
          map['validUntil'] != null ? BigInt.parse(map['validUntil']) : null,
      callGasLimit: BigInt.parse(map['callGasLimit']),
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
  final Future<FilterEvent?> Function({int millisecond}) wait;

  UserOperationResponse(this.userOpHash, this.wait);
}
