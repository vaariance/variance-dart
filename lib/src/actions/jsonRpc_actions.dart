part of '../../variance_dart.dart';

/// A stateless mixin that implements the JsonRPCProviderBase interface and provides methods
/// for interacting with an Ethereum-like blockchain via the JSON-RPC protocol.
/// This mixin contains core JSON-RPC actions like estimating gas, getting block
/// information, and retrieving gas prices.
mixin _JsonRPCActions on SmartWalletBase implements JsonRPCProviderBase {
  @override
  Future<BigInt> balanceOf(
    Address? address, {
    BlockNum atBlock = const BlockNum.current(),
  }) {
    if (address == null) {
      return Future.value(BigInt.zero);
    }
    return state.jsonRpc
        .send<String>('eth_getBalance', [
          address.with0x,
          atBlock.toBlockParam(),
        ])
        .then(BigInt.parse);
  }

  @override
  Future<bool> deployed(
    Address? address, {
    BlockNum atBlock = const BlockNum.current(),
  }) {
    if (address == null) {
      return Future.value(false);
    }
    final isDeployed = state.jsonRpc
        .send<String>('eth_getCode', [address.with0x, atBlock.toBlockParam()])
        .then(hexToBytes)
        .then((value) => value.isNotEmpty);
    return isDeployed;
  }

  @override
  Future<BigInt> estimateGas(Address to, String calldata) {
    return state.jsonRpc
        .send<String>('eth_estimateGas', [
          {'to': to.with0x, 'data': calldata},
        ])
        .then(hexToInt);
  }

  @override
  Future<BlockInfo> getBlockInformation({
    String blockNumber = 'latest',
    bool isContainFullObj = true,
  }) {
    return state.jsonRpc
        .send<Dict>('eth_getBlockByNumber', [blockNumber, isContainFullObj])
        .then(
          (json) => (
            baseFeePerGas: (json['baseFeePerGas'] as String?)?.let(hexToInt),
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              hexToDartInt(json['timestamp']) * 1000,
              isUtc: true,
            ),
          ),
        );
  }

  @override
  Future<int> getBlockNumber() {
    return state.jsonRpc
        .send<String>('eth_blockNumber')
        .then(hexToInt)
        .then((value) => value.toInt());
  }

  @override
  Future<Fee> getGasPrice([GasEstimation rate = GasEstimation.normal]) async {
    try {
      final [low, medium, high] = await getGasInEIP1559(state.jsonRpc.url);
      switch (rate) {
        case GasEstimation.low:
          return low;
        case GasEstimation.normal:
          return medium;
        case GasEstimation.high:
          return high;
      }
    } catch (e) {
      final data = await state.jsonRpc.send<String>('eth_gasPrice');
      final gasPrice = hexToInt(data);
      return Fee(
        maxPriorityFeePerGas: gasPrice,
        maxFeePerGas: gasPrice,
        estimatedGas: gasPrice,
      );
    }
  }
}
