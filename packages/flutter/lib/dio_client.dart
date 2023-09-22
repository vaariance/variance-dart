import 'package:dio/dio.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/utils/4337/chains.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

import 'package:web3dart/web3dart.dart';

class DioClient {
  final Dio _dio = Dio();
  final _baseUrl = 'https://api.gelato.digital';

  // Define a class-level variable to hold the response.
  Response? _callResponse;

  Future<String?> callWithSyncFeeErc2771(
      String? payload, GelatoPayloadConfig config) async {
    final client = Web3Client(config.ethereumProviderUrl, http.Client());
    final userNonce = await client.getTransactionCount(config.userAddress);
    final userDeadline =
        DateTime.now().millisecondsSinceEpoch + config.userDeadlineOffsetMs;
    final Signer sign = Signer();
    final data = client
        .call(contract: config.contract, function: config.function, params: []);

    try {
      final response = await _dio.post(
        '$_baseUrl/relays/v2/call-with-sync-fee-erc2771',
        data: {
          "chainId": Chains.getChain(Chain.base_goerli)?.chainId,
          "target": config.target.hex,
          "data": data,
          "user": "string",
          "userNonce": userNonce,
          "userDeadline": userDeadline,
          "userSignature": sign.sign(payload, index: 0, id: "string"),
          "feeToken": config.feeToken,
          "isRelayContext": true,
          "gasLimit": config.gasLimit,
          "retries": config.retries
        },
      );
      _callResponse = response;
      return response.data.toString();
    } on DioException catch (e) {
      log(e.message!);
      return null;
    }
  }

  Response? get callResponse => _callResponse;
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
