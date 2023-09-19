// ignore_for_file: public_member_api_docs, sort_constructors_first
library passkeysafe;

import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:passkeysafe/src/utils/4337/userop.dart';
import 'package:passkeysafe/src/utils/common.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

class BaseProvider extends JsonRPC {
  BaseProvider(super.url, super.client);

  Future<T> _makeRPCCall<T>(String function, [List<dynamic>? params]) async {
    try {
      final data = await super.call(function, params);

      // ignore: only_throw_errors
      if (data is Error || data is Exception) throw data;

      return data.result as T;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      rethrow;
    }
  }

  Future<T> send<T>(String function, [List<dynamic>? params]) async {
    return await _makeRPCCall<T>(function, params);
  }
}

class BundlerProvider {
  final int _chainId;
  final String _bundlerUrl;
  final BaseProvider _bundlerClient;
  late final bool _initialized;

  BundlerProvider(int chainId, String bundlerUrl)
      : _chainId = chainId,
        _bundlerUrl = bundlerUrl,
        _bundlerClient = BaseProvider(bundlerUrl, http.Client()) {
    validateBundlerChainId();
  }

  static final Set<String> methods = {
    'eth_chainId',
    'eth_sendUserOperation',
    'eth_estimateUserOperationGas',
    'eth_getUserOperationByHash',
    'eth_getUserOperationReceipt',
    'eth_supportedEntryPoints',
  };

  static validateBundlerMethod(String method) {
    require(methods.contains(method),
        "validateMethod: method ::'$method':: is not a valid method");
  }

  Future validateBundlerChainId() async {
    final chainId = await _bundlerClient
        .send<String>('eth_chainId')
        .then(BigInt.parse)
        .then((value) => value.toInt());
    require(chainId == _chainId,
        "bundler $_bundlerUrl is on chainId $chainId, but provider is on chainId $_chainId");
    log("provider initialized");
    _initialized = true;
  }

  Future<List<String>> supportedEntryPoints() async {
    final entrypoints =
        await _bundlerClient.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypoints);
  }

  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, String entrypoint) async {
    require(_initialized, "estimateUserOpGas: Wallet Provider not initialized");
    final opGas = await _bundlerClient.send<Map<String, dynamic>>(
        'eth_estimateUserOperationGas', [userOp, entrypoint]);
    return UserOperationGas.fromMap(opGas);
  }

  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    require(_initialized, "getUserOpByHash: Wallet Provider not initialized");
    final opExtended = await _bundlerClient
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }

  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash) async {
    require(_initialized, "getUserOpReceipt: Wallet Provider not initialized");
    final opReceipt = await _bundlerClient.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }

  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, String entrypoint) async {
    require(_initialized, "sendUserOp: Wallet Provider not initialized");
    final opHash = await _bundlerClient
        .send<String>('eth_sendUserOperation', [userOp, entrypoint]);
    return UserOperationResponse(opHash, wait);
  }

  Future<FilterEvent?> wait(Future<FilterEvent?> Function(int) handler,
      {int seconds = 0}) async {
    if (seconds == 0) {
      return null;
    }
    return await handler(seconds * 1000);
  }
}
