import 'dart:typed_data';
import 'package:variance_dart/variance.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../abis/abis.dart';

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
    if (address.hex == Chains.zeroAddress.hex) {
      return Future.value(false);
    }
    final isDeployed = _provider
        .send<String>('eth_getCode', [address.hex, 'latest'])
        .then(hexToBytes)
        .then((value) => value.isNotEmpty);
    return isDeployed;
  }

  /// [getBalance] returns the amount of ether held by a contract
  /// - @param [address] is the address to get the balance of
  Future<EtherAmount> getBalance(EthereumAddress address) {
    if (address.hex == Chains.zeroAddress.hex) {
      return Future.value(EtherAmount.zero());
    }
    return _provider
        .send<String>('eth_getBalance', [address.hex, 'latest'])
        .then(BigInt.parse)
        .then((value) => EtherAmount.fromBigInt(EtherUnit.wei, value));
  }

  /// [encodeERC20ApproveCall] returns the calldata for ERC20 approval
  /// - @param [address] is the 4337 wallet address
  /// - @param [spender] is the address of the approved spender
  /// - @param [amount] is the amount to approve for the spender
  static Uint8List encodeERC20ApproveCall(
    EthereumAddress address,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    return encodeFunctionCall(
      'approve',
      address,
      ContractAbis.get('ERC20'),
      [spender, amount.getInWei],
    );
  }

  /// [encodeERC20TransferCall] returns the calldata for ERC20 transfer
  /// - @param [address] is the 4337 wallet address
  /// - @param [recipient] is the address of the recipient
  /// - @param [amount] is the amount to transfer
  static Uint8List encodeERC20TransferCall(
    EthereumAddress address,
    EthereumAddress recipient,
    EtherAmount amount,
  ) {
    return encodeFunctionCall(
      'transfer',
      address,
      ContractAbis.get('ERC20'),
      [recipient, amount.getInWei],
    );
  }

  /// [encodeERC721ApproveCall] returns the callData for ERC721
  /// {@template approve}
  /// - @param [contractAddress] is the address of the contract
  /// - @param [to] is the address to approve
  /// - @param [tokenId] is the tokenId to approve
  /// {@endtemplate}
  static Uint8List encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, BigInt tokenId) {
    return encodeFunctionCall("approve", contractAddress,
        ContractAbis.get("ERC721"), [to.hex, tokenId]);
  }

  /// [encodeERC721SafeTransferCall] encodes the callData for ERC721
  /// {@macro approve}
  /// - @param [from] is the address to transfer from
  static Uint8List encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, BigInt tokenId) {
    return encodeFunctionCall("safeTransferFrom", contractAddress,
        ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId]);
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

  /// [execute] call data for user operation
  /// - @param required walletAddress is the address of the wallet
  /// - @param optional [to] is the address or contract to send the transaction to
  /// - @param optional [amount] is the amount to send
  /// - @param optional [innerCallData] is the calldata of the inner call
  ///
  /// returns the [Uint8List] of the call data
  static Uint8List execute(EthereumAddress walletAddress,
      {required EthereumAddress to,
      EtherAmount? amount,
      Uint8List? innerCallData}) {
    final params = [
      to,
      amount ?? EtherAmount.zero().getInWei,
    ];
    if (innerCallData != null && innerCallData.isNotEmpty) {
      params.add(innerCallData);
    }
    return encodeFunctionCall(
      'execute',
      walletAddress,
      ContractAbis.get('execute'),
      params,
    );
  }

  /// [executeBatch] call data for user operation batched
  /// - @param required walletAddress is the address of the wallet
  /// - @param optional [recipients] is a list of addresses to send the transaction
  /// - @param optional [amounts] is a list of amounts to send alongside
  /// - @param optional [innerCalls] is a list of calldata of the inner calls
  ///
  /// returns the [Uint8List] of the call data
  static Uint8List executeBatch(
      {required EthereumAddress walletAddress,
      required List<EthereumAddress> recipients,
      List<EtherAmount>? amounts,
      List<Uint8List>? innerCalls}) {
    final params = [
      recipients,
      amounts ?? [],
      innerCalls ?? [],
    ];
    if (innerCalls == null || innerCalls.isEmpty) {
      require(amounts != null && amounts.isNotEmpty, "malformed batch request");
    }
    return encodeFunctionCall(
      'executeBatch',
      walletAddress,
      ContractAbis.get('executeBatch'),
      params,
    );
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

  /// [nftApproveOperation] returns a [UserOperation] to approve the spender of the NFT
  /// - @param [owner] is the address of the owner of the NFT
  /// - @param [spender] is the address of the spender of the NFT
  static UserOperation nftApproveOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender, BigInt tokenId) {
    final innerCallData = execute(owner,
        to: contractAddress,
        innerCallData: encodeERC721ApproveCall(
          contractAddress,
          spender,
          tokenId,
        ));
    return UserOperation.partial(hexlify(innerCallData));
  }

  /// [nftTransferOperation] returns a [UserOperation] to transfer an NFT
  /// - @param [owner] is the address of the owner of the NFT
  /// - @param [spender] is the address of the spender of the NFT
  static UserOperation nftTransferOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender, BigInt tokenId) {
    final innerCallData = execute(owner,
        to: contractAddress,
        innerCallData: encodeERC721SafeTransferCall(
          contractAddress,
          owner,
          spender,
          tokenId,
        ));
    return UserOperation.partial(hexlify(innerCallData));
  }

  /// [tokenApproveOperation] returns the userOperation for an ERC20 approval
  /// - @param [owner] is the 4337 wallet address
  /// - @param [spender] is the address of the approved spender
  /// - @param [amount] is the amount to approve for the spender
  /// returns the userOperation
  static UserOperation tokenApproveOperation(
    EthereumAddress contractAddress,
    EthereumAddress owner,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    final callData = execute(owner,
        to: contractAddress,
        innerCallData:
            encodeERC20ApproveCall(contractAddress, spender, amount));
    return UserOperation.partial(hexlify(callData));
  }

  /// [tokenTransferOperation] returns the userOperation for an ERC20 transfer
  /// - @param [owner] is the 4337 wallet address
  /// - @param [recipient] is the address of the recipient
  /// - @param [amount] is the amount to transfer
  /// returns the userOperation
  static UserOperation tokenTransferOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress recipient, EtherAmount amount) {
    final callData = execute(owner,
        to: contractAddress,
        innerCallData:
            encodeERC20TransferCall(contractAddress, recipient, amount));
    return UserOperation.partial(hexlify(callData));
  }
}
