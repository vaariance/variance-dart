
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/utils/4337/chains.dart';
import 'package:web3dart/web3dart.dart';

class UserOperation {
  final String sender;
  final BigInt nonce;
  final String initCode;
  final String callData;
  final BigInt callGasLimit;
  final BigInt verificationGasLimit;
  final BigInt preVerificationGas;
  final BigInt maxFeePerGas;
  final BigInt maxPriorityFeePerGas;
  final String signature;
  final String paymasterAndData;

  Uint8List hash;

  UserOperation(
    this.sender,
    this.nonce,
    this.initCode,
    this.callData,
    this.callGasLimit,
    this.verificationGasLimit,
    this.preVerificationGas,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.signature,
    this.paymasterAndData,
  ) : hash = keccak256(abi.encode([
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
          EthereumAddress.fromHex(sender),
          nonce,
          keccak256(hexToBytes(initCode)),
          keccak256(hexToBytes(callData)),
          callGasLimit,
          verificationGasLimit,
          preVerificationGas,
          maxFeePerGas,
          maxPriorityFeePerGas,
          keccak256(hexToBytes(paymasterAndData)),
        ]));

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
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

  factory UserOperation.fromMap(Map<String, dynamic> map) {
    return UserOperation(
      map['sender'],
      BigInt.parse(map['nonce'].substring(2), radix: 16),
      map['initCode'],
      map['callData'],
      BigInt.parse(map['callGasLimit'].substring(2), radix: 16),
      BigInt.parse(map['verificationGasLimit'].substring(2), radix: 16),
      BigInt.parse(map['preVerificationGas'].substring(2), radix: 16),
      BigInt.parse(map['maxFeePerGas'].substring(2), radix: 16),
      BigInt.parse(map['maxPriorityFeePerGas'].substring(2), radix: 16),
      map['signature'],
      map['paymasterAndData'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserOperation.fromJson(String source) =>
      UserOperation.fromMap(json.decode(source) as Map<String, dynamic>);

  Uint8List getHash(IChain chain) => keccak256(abi.encode(
      ['bytes32', 'address', 'uint256'],
      [keccak256(hash), chain.entrypoint, chain.chainId]));
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
      preVerificationGas:
          BigInt.parse(map['preVerificationGas'].substring(2), radix: 16),
      verificationGasLimit:
          BigInt.parse(map['verificationGasLimit'].substring(2), radix: 16),
      validAfter: map['validAfter'] != null
          ? BigInt.parse(map['validAfter'].substring(2), radix: 16)
          : null,
      validUntil: map['validUntil'] != null
          ? BigInt.parse(map['validUntil'].substring(2), radix: 16)
          : null,
      callGasLimit: BigInt.parse(map['callGasLimit'].substring(2), radix: 16),
    );
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
      BigInt.parse(map['blockNumber'].substring(2), radix: 16),
      BigInt.parse(map['blockHash'].substring(2), radix: 16),
      BigInt.parse(map['transactionHash'].substring(2), radix: 16),
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
      BigInt.parse(map['nonce'].substring(2), radix: 16),
      map['paymaster'],
      BigInt.parse(map['actualGasCost'].substring(2), radix: 16),
      BigInt.parse(map['actualGasUsed'].substring(2), radix: 16),
      map['success'],
      map['reason'],
      List.castFrom(map['logs']),
    );
  }
}

class WaitIsolateMessage {
  final int millisecond;
  final SendPort sendPort;
  WaitIsolateMessage({required this.millisecond, required this.sendPort});
}

class UserOperationResponse {
  final String userOpHash;
  final Future<FilterEvent?> Function(void Function(WaitIsolateMessage),
      {int seconds}) wait;

  UserOperationResponse(this.userOpHash, this.wait);
}
