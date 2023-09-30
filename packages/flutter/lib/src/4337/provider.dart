// ignore_for_file: public_member_api_docs, sort_constructors_first
library pks_4337_sdk;

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/chains.dart';
import 'package:pks_4337_sdk/src/abi/entrypoint.g.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

///A JsonRPC wrapper for Bundler rpc.
///Re-routes rpc calls to Bundler
class BaseProvider extends JsonRPC {
  final String _rpcUrl;
  BaseProvider(String rpcUrl)
      : _rpcUrl = rpcUrl,
        super(rpcUrl, http.Client());

  String get rpcUrl => _rpcUrl;

  Future<int> getBlockNumber() {
    return _makeRPCCall<String>('eth_blockNumber')
        .then((s) => hexToInt(s).toInt());
  }

  Future<EtherAmount> getGasPrice() async {
    final data = await _makeRPCCall<String>('eth_gasPrice');

    return EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(data));
  }

  Future<T> send<T>(String function, [List<dynamic>? params]) async {
    return await _makeRPCCall<T>(function, params);
  }

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
}

///choose what bundler provider to use
class BundlerProvider {
  static final Set<String> methods = {
    'eth_chainId',
    'eth_sendUserOperation',
    'eth_estimateUserOperationGas',
    'eth_getUserOperationByHash',
    'eth_getUserOperationReceipt',
    'eth_supportedEntryPoints',
  };
  final int _chainId;
  final String _bundlerUrl;
  final BaseProvider _bundlerClient;

  late final bool _initialized;
  Web3Client? custom;

  Entrypoint? entrypoint;

  BundlerProvider(IChain chain)
      : _chainId = chain.chainId,
        _bundlerUrl = chain.bundlerUrl!,
        _bundlerClient = BaseProvider(chain.bundlerUrl!) {
    _initializeBundlerProvider();
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

  initializeWithEntrypoint(Entrypoint ep, Web3Client bp) {
    entrypoint = ep;
    custom = bp;
  }

  ///sends user operation to bundler
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, String entrypoint) async {
    require(_initialized, "sendUserOp: Wallet Provider not initialized");
    final opHash = await _bundlerClient
        .send<String>('eth_sendUserOperation', [userOp, entrypoint]);
    return UserOperationResponse(opHash, wait);
  }

  ///returns the a list of supported entrypoint(s) for the bundler
  ///
  ///`returns`
  ///
  ///a list of supported entrypoint(s)
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList =
        await _bundlerClient.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypointList);
  }

  ///This function when called, runs in a separate [Isolate] and returns a [FilterEvent]
  ///based on an event emitted by the smart contract
  ///
  ///`returns`
  ///
  ///[FilterEvent]
  Future<FilterEvent?> wait({int seconds = 0}) async {
    if (seconds == 0) {
      return null;
    }
    final receivePort = ReceivePort();
    final completer = Completer<FilterEvent?>();

    await Isolate.spawn(
        _wait,
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

  /// checks that the bundler chainId matches expected chainId
  Future _initializeBundlerProvider() async {
    final chainId = await _bundlerClient
        .send<String>('eth_chainId')
        .then(BigInt.parse)
        .then((value) => value.toInt());
    require(chainId == _chainId,
        "bundler $_bundlerUrl is on chainId $chainId, but provider is on chainId $_chainId");
    log("provider initialized");
    _initialized = true;
  }

  /// waits for a userOp to complete.
  /// Isolates this in a separate thread
  void _wait(WaitIsolateMessage message) async {
    require(entrypoint != null && custom != null,
        "Entrypoint required! use Wallet.init");
    final block = await custom!.getBlockNumber();
    final end = DateTime.now().millisecondsSinceEpoch + message.millisecond;

    while (DateTime.now().millisecondsSinceEpoch < end) {
      final filterEvent = await custom!
          .events(
            FilterOptions.events(
              contract: entrypoint!.self,
              event: entrypoint!.self.event('UserOperationEvent'),
              fromBlock: BlockNum.exact(block - 100),
            ),
          )
          .take(1)
          .first;
      if (filterEvent.transactionHash != null) {
        Isolate.current.kill(priority: Isolate.immediate);
        message.sendPort.send(filterEvent);
        return;
      }
      await Future.delayed(Duration(milliseconds: message.millisecond));
    }

    Isolate.current.kill(priority: Isolate.immediate);
    message.sendPort.send(null);
  }

  /// Checks that [method] is a valid bundler method
  static validateBundlerMethod(String method) {
    require(methods.contains(method),
        "validateMethod: method ::'$method':: is not a valid method");
  }
}
