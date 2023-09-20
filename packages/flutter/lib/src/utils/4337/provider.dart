// ignore_for_file: public_member_api_docs, sort_constructors_first
library pks_4337_sdk;

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

///A JsonRPC wrapper for Bundler rpc.
///Re-routes rpc calls to Bundler
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

///choose what bundler provider to use
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

  /// Checks that [method] is a valid bundler method
  static validateBundlerMethod(String method) {
    require(methods.contains(method),
        "validateMethod: method ::'$method':: is not a valid method");
  }

  /// checks that the bundler chainId matches expected chainId
  /// 
  /// `returns`
  /// 
  /// `true` if the chainId matches
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

  ///returns the a list of supported entrypoints for the bundler
  ///
  ///`returns`
  ///
  ///a list of supported entrypoints
  Future<List<String>> supportedEntryPoints() async {
    final entrypoints =
        await _bundlerClient.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypoints);
  }

  ///estimates gas cost for user operation
  ///
  ///`returns`
  ///
  ///[UserOperationGas] object
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, String entrypoint) async {
    require(_initialized, "estimateUserOpGas: Wallet Provider not initialized");
    final opGas = await _bundlerClient.send<Map<String, dynamic>>(
        'eth_estimateUserOperationGas', [userOp, entrypoint]);
    return UserOperationGas.fromMap(opGas);
  }

  ///retrieves a user operation object by hash from a bundler
  ///
  ///
  ///`returns`
  ///
  ///[UserOperationByHash] object
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    require(_initialized, "getUserOpByHash: Wallet Provider not initialized");
    final opExtended = await _bundlerClient
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }
  ///gets user operation receipt
  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash) async {
    require(_initialized, "getUserOpReceipt: Wallet Provider not initialized");
    final opReceipt = await _bundlerClient.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }
  ///sends user operation to bundler
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, String entrypoint) async {
    require(_initialized, "sendUserOp: Wallet Provider not initialized");
    final opHash = await _bundlerClient
        .send<String>('eth_sendUserOperation', [userOp, entrypoint]);
    return UserOperationResponse(opHash, wait);
  }

  
  ///This function when called, runs in a separate [Isolate] and returns a [FilterEvent] 
  ///based on an event emitted by the smart contract
  ///
  ///`returns`
  ///
  ///[FilterEvent] 
  Future<FilterEvent?> wait(void Function(WaitIsolateMessage) handler,
      {int seconds = 0}) async {
    if (seconds == 0) {
      return null;
    }
    final receivePort = ReceivePort();
    final completer = Completer<FilterEvent?>();

    await Isolate.spawn(
        handler,
        WaitIsolateMessage(
            millisecond: seconds * 1000, sendPort: receivePort.sendPort));

    receivePort.listen((data) {
      if (data is FilterEvent) {
        completer.complete(data);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }
}
