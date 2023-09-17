import 'dart:convert';
import 'dart:typed_data';

import 'package:passkeysafe/utils/4337/chains.dart';
import 'package:web3dart/web3dart.dart';

import '../common.dart';

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
  final String paymasterAndData;
  final String signature;

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
    this.paymasterAndData,
    this.signature,
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
      'nonce': nonce,
      'initCode': initCode,
      'callData': callData,
      'callGasLimit': callGasLimit,
      'verificationGasLimit': verificationGasLimit,
      'preVerificationGas': preVerificationGas,
      'maxFeePerGas': maxFeePerGas,
      'maxPriorityFeePerGas': maxPriorityFeePerGas,
      'paymasterAndData': paymasterAndData,
      'signature': signature,
    };
  }

  factory UserOperation.fromMap(Map<String, dynamic> map) {
    return UserOperation(
      map['sender'] as String,
      map['nonce'] as BigInt,
      map['initCode'] as String,
      map['callData'] as String,
      map['callGasLimit'] as BigInt,
      map['verificationGasLimit'] as BigInt,
      map['preVerificationGas'] as BigInt,
      map['maxFeePerGas'] as BigInt,
      map['maxPriorityFeePerGas'] as BigInt,
      map['paymasterAndData'] as String,
      map['signature'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserOperation.fromJson(String source) =>
      UserOperation.fromMap(json.decode(source) as Map<String, dynamic>);

  Uint8List getHash(IChain chain) => keccak256(abi.encode(
      ['bytes32', 'address', 'uint256'],
      [keccak256(hash), chain.entrypoint, chain.chainId]));
}

class UserOperationResponse {
  final String userOpHash;
  final Future<FilterEvent?> Function() wait;

  UserOperationResponse(this.userOpHash, this.wait);
}

class UserOperationReceipt {
  final String entrypoint;
  final String userOpHash;
  final String revertReason;
  final String paymaster;
  final BigInt actualGasUsed;
  final BigInt actualGasCost;
  final BigInt nonce;
  final bool success;
  final List log;

  UserOperationReceipt(
      this.entrypoint,
      this.userOpHash,
      this.revertReason,
      this.paymaster,
      this.actualGasUsed,
      this.actualGasCost,
      this.nonce,
      this.success,
      this.log);
}

class ISendUserOperationResponse {
  final String userOpHash;
  final Future<FilterEvent?> Function() wait;

  ISendUserOperationResponse(this.userOpHash, this.wait);
}

class UserOperationGet {
  UserOperation userOperation;
  final String entryPoint;
  final BigInt blockNumber;
  final BigInt blockHash;
  final BigInt transactionHash;

  UserOperationGet(
    this.userOperation,
    this.entryPoint,
    this.blockNumber,
    this.blockHash,
    this.transactionHash,
  );
}
