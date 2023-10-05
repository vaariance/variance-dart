import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// A Wrapper for the Contract Object
/// for interacting with deployed contracts.
class Contract {
  BaseProvider _provider;
  Contract(
    this._provider,
  );

  BaseProvider get provider => _provider;

  set setProvider(BaseProvider provider) {
    _provider = provider;
  }

  /// [call] performs a [StaticCall] to a contract
  /// - @param [contractAddress] is the address of the contract
  /// - @param [abi] is the ABI of the contract
  /// - @param [methodName] is the name of the method in the contract
  /// - @param optional [params] additional parameters for the method
  /// - @param optional [sender] additional sender for the transaction
  Future<List<dynamic>> call(
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
    return _provider.send<String>(
        'eth_call', [call]).then((value) => func.decodeReturnValues(value));
  }

  ///[deployed] checks if a contract is deployed
  /// - @param [address] is the address of the contract
  Future<bool> deployed(EthereumAddress address) {
    final isDeployed = _provider
        .send<String>('eth_getCode', [address.hex])
        .then(hexToBytes)
        .then((value) => value.isNotEmpty);
    return isDeployed;
  }

  /// [getBalance] returns the balance of an address
  /// - @param [address] is the address to get the balance of
  Future<EtherAmount> getBalance(EthereumAddress address) {
    return _provider
        .send<String>('eth_getBalance', [address.hex])
        .then(BigInt.parse)
        .then((value) => EtherAmount.fromBigInt(EtherUnit.wei, value));
  }

  /// [encodeFunctionCall] encodes the data for a function call to be sent to a contract
  /// - @param [methodName] is the name of the method in the contract
  /// - @param [contractAddress] is the address of the contract
  /// - @param [abi] is the ABI of the contract
  /// returns the calldata as [Uint8List]
  static Uint8List encodeFunctionCall(String methodName,
      EthereumAddress contractAddress, ContractAbi abi, List<dynamic> params) {
    final func = getContractFunction(methodName, contractAddress, abi);
    return func.encodeCall(params);
  }

  /// [getContractFunction] gets a contract function instance for a given method
  /// - @param [methodName] is the name of the method in the contract
  /// - @param [contractAddress] is the address of the contract
  /// - @param [abi] is the ABI of the contract
  /// returns a [ContractFunction]
  static ContractFunction getContractFunction(
      String methodName, EthereumAddress contractAddress, ContractAbi abi) {
    final instance = DeployedContract(abi, contractAddress);
    return instance.function(methodName);
  }
}
