import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Contract {
  BaseProvider _provider;
  Contract(
    this._provider,
  );
  BaseProvider get provider => _provider;

  set setProvider(BaseProvider provider) {
    _provider = provider;
  }

  Future<List<T>> call<T>(
      EthereumAddress contractAddress, ContractAbi abi, String methodName,
      {List<dynamic>? params, EthereumAddress? sender}) {
    final func = getContractFunction(methodName, contractAddress, abi);
    final call = {
      'to': contractAddress.hex,
      'data': params != null
          ? bytesToHex(func.encodeCall(params),
              include0x: true, padToEvenLength: true)
          : "0x",
      if (sender != null) 'from': sender.hex,
    };
    return _provider.send<String>('eth_call', [call]).then(
        (value) => func.decodeReturnValues(value) as List<T>);
  }

  Future<bool> deployed(EthereumAddress address) {
    return _provider
        .send<String>('eth_getCode', [address.hex])
        .then(hexToBytes)
        .then((value) => value.isNotEmpty);
  }

  Future<EtherAmount> getBalance(EthereumAddress address) {
    return _provider
        .send<String>('eth_getBalance', [address.hex])
        .then(BigInt.parse)
        .then((value) => EtherAmount.fromBigInt(EtherUnit.wei, value));
  }

  static Uint8List encodeFunctionCall(String methodName,
      EthereumAddress contractAddress, ContractAbi abi, List<dynamic> params) {
    final func = getContractFunction(methodName, contractAddress, abi);
    return func.encodeCall(params);
  }

  static ContractFunction getContractFunction(
      String methodName, EthereumAddress contractAddress, ContractAbi abi) {
    final instance = DeployedContract(abi, contractAddress);
    return instance.function(methodName);
  }
}
