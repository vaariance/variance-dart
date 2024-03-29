part of '../../variance.dart';

class BundlerProvider implements BundlerProviderBase {
  final RPCBase rpc;

  BundlerProvider(Chain chain)
      : assert(isURL(chain.bundlerUrl), InvalidBundlerUrl(chain.bundlerUrl)),
        rpc = RPCBase(chain.bundlerUrl!) {
    rpc
        .send<String>('eth_chainId')
        .then(BigInt.parse)
        .then((value) => value.toInt() == chain.chainId)
        .then((value) => _initialized = value == true);
  }

  late final bool _initialized;

  @override
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EntryPointAddress entrypoint) async {
    Logger.conditionalWarning(
        !_initialized, "estimateUserOpGas may fail: chainId mismatch");
    final opGas = await rpc.send<Map<String, dynamic>>(
        'eth_estimateUserOperationGas', [userOp, entrypoint.address.hex]);
    return UserOperationGas.fromMap(opGas);
  }

  @override
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    Logger.conditionalWarning(
        !_initialized, "getUserOpByHash may fail: chainId mismatch");
    final opExtended = await rpc
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }

  @override
  Future<UserOperationReceipt?> getUserOpReceipt(String userOpHash) async {
    Logger.conditionalWarning(
        !_initialized, "getUserOpReceipt may fail: chainId mismatch");
    final opReceipt = await rpc.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }

  @override
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, EntryPointAddress entrypoint) async {
    Logger.conditionalWarning(
        !_initialized, "sendUserOp may fail: chainId mismatch");
    final opHash = await rpc.send<String>(
        'eth_sendUserOperation', [userOp, entrypoint.address.hex]);
    return UserOperationResponse(opHash, getUserOpReceipt);
  }

  @override
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList =
        await rpc.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypointList);
  }
}

class JsonRPCProvider implements JsonRPCProviderBase {
  final RPCBase rpc;

  JsonRPCProvider(Chain chain)
      : assert(isURL(chain.jsonRpcUrl), InvalidJsonRpcUrl(chain.jsonRpcUrl)),
        rpc = RPCBase(chain.jsonRpcUrl!);

  @override
  Future<BigInt> estimateGas(EthereumAddress to, String calldata) {
    return rpc.send<String>('eth_estimateGas', [
      {'to': to.hex, 'data': calldata}
    ]).then(hexToInt);
  }

  @override
  Future<int> getBlockNumber() {
    return rpc
        .send<String>('eth_blockNumber')
        .then(hexToInt)
        .then((value) => value.toInt());
  }

  @override
  Future<Map<String, EtherAmount>> getEip1559GasPrice() async {
    final fee = await rpc.send<String>("eth_maxPriorityFeePerGas");
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

  @override
  Future<Map<String, EtherAmount>> getGasPrice() async {
    try {
      return await getEip1559GasPrice();
    } catch (e) {
      final value = await getLegacyGasPrice();
      return {
        'maxFeePerGas': value,
        'maxPriorityFeePerGas': value,
      };
    }
  }

  @override
  Future<EtherAmount> getLegacyGasPrice() async {
    final data = await rpc.send<String>('eth_gasPrice');
    return EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(data));
  }
}

class RPCBase extends JsonRPC {
  RPCBase(String url) : super(url, http.Client());

  /// Asynchronously sends an RPC call to the Ethereum node for the specified function and parameters.
  ///
  /// Parameters:
  ///   - `function`: The Ethereum RPC function to call. eg: `eth_getBalance`
  ///   - `params`: Optional parameters for the RPC call.
  ///
  /// Returns:
  ///   A [Future] that completes with the result of the RPC call.
  ///
  /// Example:
  /// ```dart
  /// var result = await send<String>('eth_getBalance', ['0x9876543210abcdef9876543210abcdef98765432']);
  /// ```
  Future<T> send<T>(String function, [List<dynamic>? params]) {
    return _makeRPCCall<T>(function, params);
  }

  Future<T> _makeRPCCall<T>(String function, [List<dynamic>? params]) {
    return super.call(function, params).then((data) => data.result as T);
  }
}
