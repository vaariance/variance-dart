library pks_4337_sdk;

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/abi/entrypoint.g.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

///A JsonRPC wrapper for Bundler rpc.
class BaseProvider extends JsonRPC {
  BaseProvider(String rpcUrl) : super(rpcUrl, http.Client());

  /// - @param [to] is the address or contract to send the transaction to
  /// - @param [calldata] is the calldata of the transaction
  /// - returns the estimated gas in wei.
  Future<BigInt> estimateGas(
    EthereumAddress to,
    String calldata,
  ) async {
    final amountHex = await _makeRPCCall<String>('eth_estimateGas', [
      {'to': to.hex, 'data': calldata}
    ]);
    return hexToInt(amountHex);
  }

  /// 
  Future<int> getBlockNumber() {
    return _makeRPCCall<String>('eth_blockNumber')
        .then((s) => hexToInt(s).toInt());
  }

  ///[getEip1559GasPrice] returns the EIP1559 gas price in wei for a network
  Future<Map<String, EtherAmount>> getEip1559GasPrice() async {
    final fee = await _makeRPCCall<String>("eth_maxPriorityFeePerGas");
    final tip = Uint256.fromHex(fee);
    final mul = Uint256(BigInt.from(100 * 13));
    final buffer = tip / mul;
    final maxPriorityFeePerGas = tip + buffer;
    final maxFeePerGas = maxPriorityFeePerGas;
    return {
      'maxFeePerGas': EtherAmount.fromBigInt(EtherUnit.wei, maxFeePerGas.value),
      'maxPriorityFeePerGas':
          EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas.value)
    };
  }
  ///[getLegacyGasPrice] returns the legacy gas price in wei for a network
  Future<Map<String, EtherAmount>> getGasPrice() async {
    try {
      return await getEip1559GasPrice();
    } catch (e) {
      try {
        return await getLegacyGasPrice().then(
            (value) => {'maxFeePerGas': value, 'maxPriorityFeePerGas': value});
      } catch (e) {
        return {
          'maxFeePerGas': EtherAmount.zero(),
          'maxPriorityFeePerGas': EtherAmount.zero()
        };
      }
    }
  }

  Future<EtherAmount> getLegacyGasPrice() async {
    final data = await _makeRPCCall<String>('eth_gasPrice');
    return EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(data));
  }

  /// [send] sends a transaction to the bundler
  /// - @param [function] is the method to call
  /// - @param [params] is the parameters for request
  /// returns an rpc response
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

  Entrypoint? entrypoint;

  BundlerProvider(IChain chain)
      : _chainId = chain.chainId,
        _bundlerUrl = chain.bundlerUrl!,
        _bundlerClient = BaseProvider(chain.bundlerUrl!) {
    _initializeBundlerProvider();
  }

  ///[estimateUserOperationGas] estimates gas cost for user operation
  /// - @param [userOp] is the user operation
  /// - @param [entrypoint] is the entrypoint address operation should pass through
  /// returns a [UserOperationGas] object
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EthereumAddress entrypoint) async {
    require(_initialized, "estimateUserOpGas: Wallet Provider not initialized");
    final opGas = await _bundlerClient.send<Map<String, dynamic>>(
        'eth_estimateUserOperationGas', [userOp, entrypoint.hex]);
    return UserOperationGas.fromMap(opGas);
  }

  ///[getUserOperationByHash]retrieves a user operation object associated to a userOpHash
  /// - @param [userOpHash] is a hashed string of the user operation
  /// returns a [UserOperationByHash] object
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    require(_initialized, "getUserOpByHash: Wallet Provider not initialized");
    final opExtended = await _bundlerClient
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }

  ///[getUserOpReceipt] retrieves a user operation receipt associated to a userOpHash
  /// - @param [userOpHash] is a hashed string of the user operation
  /// returns a [UserOperationReceipt] object
  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash) async {
    require(_initialized, "getUserOpReceipt: Wallet Provider not initialized");
    final opReceipt = await _bundlerClient.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }

  void initializeWithEntrypoint(Entrypoint ep) {
    entrypoint = ep;
  }

  ///[sendUserOperation] sends a user operation to the given network
  /// - @param [userOp] is the user operation
  /// - @param [entrypoint] is the entrypoint address operation should pass through
  /// returns a [UserOperationResponse]  object
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, EthereumAddress entrypoint) async {
    require(_initialized, "sendUserOp: Wallet Provider not initialized");
    final opHash = await _bundlerClient
        .send<String>('eth_sendUserOperation', [userOp, entrypoint.hex]);
    return UserOperationResponse(opHash, wait);
  }

  ///[supportedEntryPoints] returns the a list of supported entrypoint(s) for the bundler
  ///
  ///`returns`
  ///
  ///a list of supported entrypoint(s)
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList =
        await _bundlerClient.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypointList);
  }

  ///[wait] when called, runs in a separate [Isolate] and 
  ///returns a [FilterEvent] based on an event emitted by the smart contract
  Future<FilterEvent?> wait({int millisecond = 0}) async {
    if (millisecond == 0) {
      return null;
    }
    require(entrypoint != null, "Entrypoint required! use Wallet.init");
    final block = await entrypoint!.client.getBlockNumber();
    final end = DateTime.now().millisecondsSinceEpoch + millisecond;

    return await Isolate.run(() async {
      while (DateTime.now().millisecondsSinceEpoch < end) {
        final filterEvent = await entrypoint!.client
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
          return filterEvent;
        }
        await Future.delayed(Duration(milliseconds: millisecond));
      }
      return null;
    });
  }

  ///[_initializeBundlerProvider] checks that the bundler chainId matches expected chainId
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

  /// Checks that [method] is a valid bundler method
  static validateBundlerMethod(String method) {
    require(methods.contains(method),
        "validateMethod: method ::'$method':: is not a valid method");
  }
}
