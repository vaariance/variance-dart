
import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Contract {
  BaseProvider _provider;
  BaseProvider get provider => _provider;
  set setProvider(BaseProvider provider) {
    _provider = provider;
  }

  Contract(
    this._provider,
  );

  static ContractFunction getContractFunction(
      String methodName, EthereumAddress contractAddress, ContractAbi abi) {
    final instance = DeployedContract(abi, contractAddress);
    return instance.function(methodName);
  }

  static Uint8List encodeFunctionCall(String methodName,
      EthereumAddress contractAddress, ContractAbi abi, List<dynamic> params) {
    final func = getContractFunction(methodName, contractAddress, abi);
    return func.encodeCall(params);
  }

  Future<List<T>> call<T>(
      EthereumAddress? sender,
      EthereumAddress contractAddress,
      ContractAbi abi,
      String methodName,
      List<dynamic> params) {
    final func = getContractFunction(methodName, contractAddress, abi);
    final call = {
      'to': contractAddress.hex,
      'data': bytesToHex(func.encodeCall(params),
          include0x: true, padToEvenLength: true),
      if (sender != null) 'from': sender.hex,
    };
    return _provider.send<String>('eth_call', [call]).then(
        (value) => func.decodeReturnValues(value) as List<T>);
  }

  Future<EtherAmount> getBalance(EthereumAddress address) async {
    final String balance =
        await _provider.send<String>('eth_getBalance', [address.hex]);
    return EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(balance));
  }

  Future<bool> deployed(EthereumAddress address) async {
    final String code =
        await _provider.send<String>('eth_getCode', [address.hex]);
    return hexToBytes(code).isNotEmpty;
  }
}
