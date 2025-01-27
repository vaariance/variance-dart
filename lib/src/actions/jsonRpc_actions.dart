part of '../../variance_dart.dart';

/// A mixin that implements the JsonRPCProviderBase interface and provides methods
/// for interacting with an Ethereum-like blockchain via the JSON-RPC protocol.
/// This mixin contains core JSON-RPC actions like estimating gas, getting block
/// information, and retrieving gas prices.
mixin _jsonRPCActions implements JsonRPCProviderBase {
  /// The remote procedure call (RPC) client used to communicate with the blockchain.
  late final RPCBase _jsonRpc;

  @override
  Future<EtherAmount> balanceOf(EthereumAddress? address,
      {BlockNum atBlock = const BlockNum.current()}) {
    if (address == null) {
      return Future.value(EtherAmount.zero());
    }
    return _jsonRpc
        .send<String>('eth_getBalance', [address.hex, atBlock.toBlockParam()])
        .then(BigInt.parse)
        .then((value) => EtherAmount.fromBigInt(EtherUnit.wei, value));
  }

  @override
  Future<bool> deployed(EthereumAddress? address,
      {BlockNum atBlock = const BlockNum.current()}) {
    if (address == null) {
      return Future.value(false);
    }
    final isDeployed = _jsonRpc
        .send<String>('eth_getCode', [address.hex, atBlock.toBlockParam()])
        .then(hexToBytes)
        .then((value) => value.isNotEmpty);
    return isDeployed;
  }

  @override
  Future<BigInt> estimateGas(EthereumAddress to, String calldata) {
    return _jsonRpc.send<String>('eth_estimateGas', [
      {'to': to.hex, 'data': calldata}
    ]).then(hexToInt);
  }

  @override
  Future<BlockInformation> getBlockInformation({
    String blockNumber = 'latest',
    bool isContainFullObj = true,
  }) {
    return _jsonRpc.send<Map<String, dynamic>>(
      'eth_getBlockByNumber',
      [blockNumber, isContainFullObj],
    ).then((json) => BlockInformation.fromJson(json));
  }

  @override
  Future<int> getBlockNumber() {
    return _jsonRpc
        .send<String>('eth_blockNumber')
        .then(hexToInt)
        .then((value) => value.toInt());
  }

  @override
  Future<Fee> getGasPrice([GasEstimation rate = GasEstimation.normal]) async {
    try {
      final [low, medium, high] = await getGasInEIP1559(_jsonRpc.url);
      switch (rate) {
        case GasEstimation.low:
          return low;
        case GasEstimation.normal:
          return medium;
        case GasEstimation.high:
          return high;
      }
    } catch (e) {
      final data = await _jsonRpc.send<String>('eth_gasPrice');
      final gasPrice = hexToInt(data);
      return Fee(
          maxPriorityFeePerGas: gasPrice,
          maxFeePerGas: gasPrice,
          estimatedGas: gasPrice);
    }
  }

  @override
  Future<List<dynamic>> readContract(
      EthereumAddress contractAddress, ContractAbi abi, String methodName,
      {List<dynamic>? params, EthereumAddress? sender}) {
    final function =
        Contract.getContractFunction(methodName, contractAddress, abi);
    final calldata = {
      'to': contractAddress.hex,
      'data': params != null
          ? bytesToHex(function.encodeCall(params),
              include0x: true, padToEvenLength: true)
          : "0x",
      if (sender != null) 'from': sender.hex,
    };
    return _jsonRpc.send<String>('eth_call', [
      calldata,
      BlockNum.current().toBlockParam()
    ]).then((value) => function.decodeReturnValues(value));
  }

  /// Initializes the JSON-RPC actions with the provided RPC client.
  ///
  /// [rpc] The RPC client instance used to communicate with the blockchain network.
  /// This client handles the low-level communication between the application and
  /// the blockchain node.
  void _setupJsonRpcActions(RPCBase rpc) {
    _jsonRpc = rpc;
  }
}
