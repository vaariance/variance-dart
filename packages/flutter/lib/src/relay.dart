import 'dart:convert';

import 'package:web3dart/web3dart.dart';

class Relay {
  String? payload;
  Future relay() async {}
}

class CallWithSyncFeeErc2771 {
  BigInt? chainId;
  String? target;
  String? data;
  String? user;
  BigInt? userNonce;
  String? userSignature;
  BigInt? userDeadline;
  String? feeToken;
  bool? isRelayContext;
  String? sponsorApiKey;
  String? gasLimits;
  BigInt? retries;
  CallWithSyncFeeErc2771({
    this.chainId,
    this.target,
    this.data,
    this.user,
    this.userNonce,
    this.userSignature,
    this.userDeadline,
    this.feeToken,
    this.isRelayContext,
    this.sponsorApiKey,
    this.gasLimits,
    this.retries,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chainId': chainId,
      'target': target,
      'data': data,
      'user': user,
      'userNonce': userNonce,
      'userSignature': userSignature,
      'userDeadline': userDeadline,
      'feeToken': feeToken,
      'isRelayContext': isRelayContext,
      'sponsorApiKey': sponsorApiKey,
      'gasLimits': gasLimits,
      'retries': retries,
    };
  }

  factory CallWithSyncFeeErc2771.fromJson(Map<String, dynamic> json) {
    return CallWithSyncFeeErc2771(
      chainId: json['chainId'] != null ? BigInt.parse(json['chainId']) : null,
      target: json['target'] as String?,
      data: json['data'] as String?,
      user: json['user'] as String?,
      userNonce:
          json['userNonce'] != null ? BigInt.parse(json['userNonce']) : null,
      userSignature: json['userSignature'] as String?,
      userDeadline: json['userDeadline'] != null
          ? BigInt.parse(json['userDeadline'])
          : null,
      feeToken: json['feeToken'] as String?,
      isRelayContext: json['isRelayContext'] as bool?,
      sponsorApiKey: json['sponsorApiKey'] as String?,
      gasLimits: json['gasLimits'] as String?,
      retries: json['retries'] != null ? BigInt.parse(json['retries']) : null,
    );
  }

  String toJson() => json.encode(toMap());
}


class GelatoPayloadConfig {
  final String ethereumProviderUrl;
  final EthereumAddress target;
  final String feeToken;
  final String functionName;
  final DeployedContract contract;
  final ContractFunction function;
  final List<dynamic> functionParams;
  final EthereumAddress userAddress;
  final int retries;
  final String gasLimit;
  final int userDeadlineOffsetMs;

  GelatoPayloadConfig(
    this.contract,
    this.function, {
    required this.ethereumProviderUrl,
    required this.target,
    required this.feeToken,
    required this.functionName,
    required this.functionParams,
    required this.userAddress,
    required this.retries,
    required this.gasLimit,
    required this.userDeadlineOffsetMs,
  });
}
