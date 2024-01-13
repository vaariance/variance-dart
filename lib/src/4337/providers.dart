part of '../../variance.dart';

class BundlerProvider implements BundlerProviderBase {
  /// Set of Ethereum RPC methods supported by the SmartWallet SDK.
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
  final RPCProviderBase _bundlerRpc;

  late final bool _initialized;

  Entrypoint? entrypoint;

  BundlerProvider(Chain chain, RPCProviderBase bundlerRpc)
      : _chainId = chain.chainId,
        _bundlerUrl = chain.bundlerUrl!,
        _bundlerRpc = bundlerRpc {
    _initializeBundlerProvider();
  }

  @override
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EthereumAddress entrypoint) async {
    require(_initialized, "estimateUserOpGas: Wallet Provider not initialized");
    final opGas = await _bundlerRpc.send<Map<String, dynamic>>(
        'eth_estimateUserOperationGas', [userOp, entrypoint.hex]);
    return UserOperationGas.fromMap(opGas);
  }

  @override
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    require(_initialized, "getUserOpByHash: Wallet Provider not initialized");
    final opExtended = await _bundlerRpc
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }

  @override
  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash) async {
    require(_initialized, "getUserOpReceipt: Wallet Provider not initialized");
    final opReceipt = await _bundlerRpc.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }

  @override
  void initializeWithEntrypoint(Entrypoint ep) {
    entrypoint = ep;
  }

  @override
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, EthereumAddress entrypoint) async {
    require(_initialized, "sendUserOp: Wallet Provider not initialized");
    final opHash = await _bundlerRpc
        .send<String>('eth_sendUserOperation', [userOp, entrypoint.hex]);
    return UserOperationResponse(opHash, wait);
  }

  @override
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList =
        await _bundlerRpc.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypointList);
  }

  @override
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

  Future _initializeBundlerProvider() async {
    final chainId = await _bundlerRpc
        .send<String>('eth_chainId')
        .then(BigInt.parse)
        .then((value) => value.toInt());
    require(chainId == _chainId,
        "bundler $_bundlerUrl is on chainId $chainId, but provider is on chainId $_chainId");
    _initialized = true;
  }

  /// Validates if the provided method is a supported RPC method.
  ///
  /// Parameters:
  ///   - `method`: The Ethereum RPC method to validate.
  ///
  /// Throws:
  ///   - A [Exception] if the method is not a valid supported method.
  ///
  /// Example:
  /// ```dart
  /// validateBundlerMethod('eth_sendUserOperation');
  /// ```
  static validateBundlerMethod(String method) {
    require(methods.contains(method),
        "validateMethod: method ::'$method':: is not a valid method");
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
