import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/chains.dart';
import 'package:web3dart/crypto.dart' as crypto;
import 'package:web3dart/web3dart.dart';

class UserOperation {
  final EthereumAddress sender;
  final BigInt nonce;
  final Uint8List initCode;
  final Uint8List callData;
  final BigInt callGasLimit;
  final BigInt verificationGasLimit;
  final BigInt preVerificationGas;
  final BigInt maxFeePerGas;
  final BigInt maxPriorityFeePerGas;
  Uint8List signature;
  final String paymasterAndData;

  Uint8List _hash;
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
  ) : _hash = keccak256(abi.encode([
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
          keccak256(Uint8List.fromList(crypto.hexToBytes(paymasterAndData))),
        ]));

  factory UserOperation.fromJson(String source) =>
      UserOperation.fromMap(json.decode(source) as Map<String, dynamic>);

  factory UserOperation.fromMap(Map<String, dynamic> map) {
    return UserOperation(
      EthereumAddress.fromHex(map['sender']),
      BigInt.parse(map['nonce']),
      crypto.hexToBytes(map['initCode']),
      crypto.hexToBytes(map['callData']),
      BigInt.parse(map['callGasLimit']),
      BigInt.parse(map['verificationGasLimit']),
      BigInt.parse(map['preVerificationGas']),
      BigInt.parse(map['maxFeePerGas']),
      BigInt.parse(map['maxPriorityFeePerGas']),
      crypto.hexToBytes(map['signature']),
      map['paymasterAndData'],
    );
  }

  Uint8List hash(IChain chain) => keccak256(abi.encode(
      ['bytes32', 'address', 'uint256'],
      [keccak256(_hash), chain.entrypoint, chain.chainId]));

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender.hexEip55,
      'nonce': '0x${nonce.toRadixString(16)}',
      'initCode': hexlify(initCode),
      'callData': hexlify(callData),
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'verificationGasLimit': '0x${verificationGasLimit.toRadixString(16)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      'maxFeePerGas': '0x${maxFeePerGas.toRadixString(16)}',
      'maxPriorityFeePerGas': '0x${maxPriorityFeePerGas.toRadixString(16)}',
      'signature': hexlify(signature),
      'paymasterAndData': paymasterAndData,
    };
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
  final Future<FilterEvent?> Function({int seconds}) wait;

  UserOperationResponse(this.userOpHash, this.wait);
}

class WaitIsolateMessage {
  final int millisecond;
  final SendPort sendPort;
  WaitIsolateMessage({required this.millisecond, required this.sendPort});
}
