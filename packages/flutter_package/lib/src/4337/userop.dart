import 'dart:convert';
import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/chains.dart';
import 'package:web3dart/crypto.dart' as crypto;
import 'package:web3dart/web3dart.dart';

/// [UserOperation] model for user operations
class UserOperation {
  final EthereumAddress sender;
  final BigInt nonce;
  final String initCode;
  final String callData;
  final BigInt callGasLimit;
  final BigInt verificationGasLimit;
  final BigInt preVerificationGas;
  BigInt maxFeePerGas;
  BigInt maxPriorityFeePerGas;
  String signature;
  String paymasterAndData;

  Uint8List _hash;

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
  }) : _hash = keccak256(abi.encode([
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
          keccak256(crypto.hexToBytes(initCode)),
          keccak256(crypto.hexToBytes(callData)),
          callGasLimit,
          verificationGasLimit,
          preVerificationGas,
          maxFeePerGas,
          maxPriorityFeePerGas,
          keccak256(crypto.hexToBytes(paymasterAndData)),
        ]));

  factory UserOperation.fromJson(String source) =>
      UserOperation.fromMap(json.decode(source) as Map<String, dynamic>);

  factory UserOperation.fromMap(Map<String, dynamic> map) {
    return UserOperation(
      sender: EthereumAddress.fromHex(map['sender']),
      nonce: BigInt.parse(map['nonce']),
      initCode: map['initCode'],
      callData: map['callData'],
      callGasLimit: BigInt.parse(map['callGasLimit']),
      verificationGasLimit: BigInt.parse(map['verificationGasLimit']),
      preVerificationGas: BigInt.parse(map['preVerificationGas']),
      maxFeePerGas: BigInt.parse(map['maxFeePerGas']),
      maxPriorityFeePerGas: BigInt.parse(map['maxPriorityFeePerGas']),
      signature: map['signature'],
      paymasterAndData: map['paymasterAndData'],
    );
  }

  factory UserOperation.partial(
    String callData, {
    EthereumAddress? sender,
    BigInt? nonce,
    String? initCode,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) =>
      UserOperation(
        sender: sender ?? Chains.zeroAddress,
        nonce: nonce ?? BigInt.zero,
        initCode: initCode ?? "0x",
        callData: callData,
        callGasLimit: callGasLimit ?? BigInt.from(35000),
        verificationGasLimit: verificationGasLimit ?? BigInt.from(70000),
        preVerificationGas: preVerificationGas ?? BigInt.from(21000),
        maxFeePerGas: maxFeePerGas ?? BigInt.zero,
        maxPriorityFeePerGas: maxPriorityFeePerGas ?? BigInt.zero,
        signature: "0x",
        paymasterAndData: '0x',
      );

  factory UserOperation.update(
    Map<String, dynamic> map,
    UserOperationGas opGas, {
    EthereumAddress? sender,
    BigInt? nonce,
    String? initCode,
  }) {
    map['callGasLimit'] = opGas.callGasLimit;
    map['verificationGasLimit'] = opGas.verificationGasLimit;
    map['preVerificationGas'] = opGas.preVerificationGas;

    if (sender != null) map['sender'] = sender.hex;
    if (nonce != null) map['nonce'] = '0x${nonce.toRadixString(16)}';
    if (initCode != null) map['initCode'] = initCode;

    return UserOperation.fromMap(map);
  }

  Uint8List hash(IChain chain) => keccak256(abi.encode(
      ['bytes32', 'address', 'uint256'],
      [keccak256(_hash), chain.entrypoint, chain.chainId]));

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender.hexEip55,
      'nonce': '0x${nonce.toRadixString(16)}',
      'initCode': initCode,
      'callData': callData,
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'verificationGasLimit': '0x${verificationGasLimit.toRadixString(16)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      'maxFeePerGas': '0x${maxFeePerGas.toRadixString(16)}',
      'maxPriorityFeePerGas': '0x${maxPriorityFeePerGas.toRadixString(16)}',
      'signature': signature,
      'paymasterAndData': paymasterAndData,
    };
  }
}

/// [UserOperationByHash] model for user operations hash
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
