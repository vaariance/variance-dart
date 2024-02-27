part of '../../variance.dart';

class BundlerProvider implements BundlerProviderBase {
  final Chain _chain;
  final RPCProviderBase _rpc;

  late final bool _initialized;

  BundlerProvider(this._chain, this._rpc) {
    _initializeBundlerProvider();
  }

  @override
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EntryPoint entrypoint) async {
    require(_initialized, "estimateUserOpGas: Wallet Provider not initialized");
    final opGas = await _rpc.send<Map<String, dynamic>>(
        'eth_estimateUserOperationGas', [userOp, entrypoint.hex]);
    return UserOperationGas.fromMap(opGas);
  }

  @override
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    require(_initialized, "getUserOpByHash: Wallet Provider not initialized");
    final opExtended = await _rpc
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }

  @override
  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash) async {
    require(_initialized, "getUserOpReceipt: Wallet Provider not initialized");
    final opReceipt = await _rpc.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }

  @override
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, EntryPoint entrypoint) async {
    require(_initialized, "sendUserOp: Wallet Provider not initialized");
    final opHash = await _rpc
        .send<String>('eth_sendUserOperation', [userOp, entrypoint.hex]);
    return UserOperationResponse(opHash);
  }

  @override
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList =
        await _rpc.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypointList);
  }

  Future _initializeBundlerProvider() async {
    final chainId = await _rpc
        .send<String>('eth_chainId')
        .then(BigInt.parse)
        .then((value) => value.toInt());
    require(chainId == _chain.chainId,
        "bundler ${_rpc.url} is on chainId $chainId, but provider is on chainId ${_chain.chainId}");
    _initialized = true;
  }
}

class RPCProvider extends JsonRPC implements RPCProviderBase {
  RPCProvider(String url) : super(url, http.Client());

  @override
  Future<BigInt> estimateGas(EthereumAddress to, String calldata) {
    return _makeRPCCall<String>('eth_estimateGas', [
      {'to': to.hex, 'data': calldata}
    ]).then(hexToInt);
  }

  @override
  Future<int> getBlockNumber() {
    return _makeRPCCall<String>('eth_blockNumber')
        .then(hexToInt)
        .then((value) => value.toInt());
  }

  @override
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
    final data = await _makeRPCCall<String>('eth_gasPrice');
    return EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(data));
  }

  @override
  Future<T> send<T>(String function, [List<dynamic>? params]) {
    return _makeRPCCall<T>(function, params);
  }

  Future<T> _makeRPCCall<T>(String function, [List<dynamic>? params]) {
    return super.call(function, params).then((data) => data.result as T);
  }
}
