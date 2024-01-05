part of 'common.dart';

/// A wrapper for interacting with deployed Ethereum contracts through RPCProviderBase.
///
/// The Contract class provides methods to perform various operations on Ethereum smart contracts,
/// including making static calls, checking deployment status, getting contract balance,
/// and encoding data for common operations like ERC20 approvals and transfers.
class Contract {
  RPCProviderBase _provider;

  Contract(
    this._provider,
  );

  RPCProviderBase get provider => _provider;

  set setProvider(RPCProviderBase provider) {
    _provider = provider;
  }

  /// Performs a static call to a contract method.
  ///
  /// - [contractAddress]: The address of the contract.
  /// - [abi]: The ABI (Application Binary Interface) of the contract.
  /// - [methodName]: The name of the method in the contract.
  /// - [params]: Additional parameters for the method.
  /// - [sender]: Additional sender for the transaction.
  ///
  /// Returns a list of dynamic values representing the result of the static call.
  Future<List<dynamic>> call(
      EthereumAddress contractAddress, ContractAbi abi, String methodName,
      {List<dynamic>? params, EthereumAddress? sender}) {
    final function = getContractFunction(methodName, contractAddress, abi);
    final calldata = {
      'to': contractAddress.hex,
      'data': params != null
          ? bytesToHex(function.encodeCall(params),
              include0x: true, padToEvenLength: true)
          : "0x",
      if (sender != null) 'from': sender.hex,
    };
    return _provider.send<String>('eth_call', [calldata]).then(
        (value) => function.decodeReturnValues(value));
  }

  /// Checks if a contract is deployed.
  ///
  /// - [address]: The address of the contract.
  /// - optional [atBlock]: The block number to check. defaults to the current block
  ///
  /// Returns a Future<bool> indicating whether the contract is deployed or not.
  Future<bool> deployed(EthereumAddress? address,
      {BlockNum atBlock = const BlockNum.current()}) {
    if (address == null) {
      return Future.value(false);
    }
    final isDeployed = _provider
        .send<String>('eth_getCode', [address.hex, atBlock.toBlockParam()])
        .then(hexToBytes)
        .then((value) => value.isNotEmpty);
    return isDeployed;
  }

  /// Gets the amount of Ether held by a contract.
  ///
  /// - [address]: The address to get the balance of.
  ///
  /// Returns a Future<EtherAmount> representing the balance.
  Future<EtherAmount> getBalance(EthereumAddress? address,
      {BlockNum atBlock = const BlockNum.current()}) {
    if (address == null) {
      return Future.value(EtherAmount.zero());
    }
    return _provider
        .send<String>('eth_getBalance', [address.hex, atBlock.toBlockParam()])
        .then(BigInt.parse)
        .then((value) => EtherAmount.fromBigInt(EtherUnit.wei, value));
  }

  /// Encodes the calldata for ERC20 approval.
  ///
  /// - [address]: The 4337 wallet address.
  /// - [spender]: The address of the approved spender.
  /// - [amount]: The amount to approve for the spender.
  ///
  /// Returns a Uint8List representing the calldata.
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

  /// Encodes the calldata for ERC20 transfer.
  ///
  /// - [address]: The 4337 wallet address.
  /// - [recipient]: The address of the recipient.
  /// - [amount]: The amount to transfer.
  ///
  /// Returns a Uint8List representing the calldata.
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

  /// Encodes the calldata for ERC721 approval.
  ///
  /// - [contractAddress]: The address of the contract.
  /// - [to]: The address to approve.
  /// - [tokenId]: The tokenId to approve.
  ///
  /// Returns a Uint8List representing the calldata.
  static Uint8List encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, BigInt tokenId) {
    return encodeFunctionCall("approve", contractAddress,
        ContractAbis.get("ERC721"), [to.hex, tokenId]);
  }

  /// Encodes the calldata for ERC721 safe transfer.
  ///
  /// - [contractAddress]: The address of the contract.
  /// - [from]: The address to transfer from.
  ///
  /// Returns a Uint8List representing the calldata.
  static Uint8List encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, BigInt tokenId) {
    return encodeFunctionCall("safeTransferFrom", contractAddress,
        ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId]);
  }

  /// Encodes the calldata for a function call.
  ///
  /// - [methodName]: The name of the method in the contract.
  /// - [contractAddress]: The address of the contract.
  /// - [abi]: The ABI of the contract.
  /// - [params]: The parameters for the method.
  ///
  /// Returns a Uint8List representing the calldata.
  static Uint8List encodeFunctionCall(String methodName,
      EthereumAddress contractAddress, ContractAbi abi, List<dynamic> params) {
    final func = getContractFunction(methodName, contractAddress, abi);
    return func.encodeCall(params);
  }

  /// Generates the calldata for a user operation.
  ///
  /// - [walletAddress]: The address of the wallet.
  /// - [to]: The address or contract to send the transaction to.
  /// - [amount]: The amount to send.
  /// - [innerCallData]: The calldata of the inner call.
  ///
  /// Returns the Uint8List of the calldata.
  static Uint8List execute(EthereumAddress walletAddress,
      {required EthereumAddress to,
      EtherAmount? amount,
      Uint8List? innerCallData}) {
    final params = [
      to,
      amount ?? EtherAmount.zero().getInWei,
      innerCallData ?? Uint8List.fromList([])
    ];

    return encodeFunctionCall(
      'execute',
      walletAddress,
      ContractAbis.get('execute'),
      params,
    );
  }

  /// Generates the calldata for a batched user operation.
  ///
  /// - [walletAddress]: The address of the wallet.
  /// - [recipients]: A list of addresses to send the transaction.
  /// - [amounts]: A list of amounts to send alongside.
  /// - [innerCalls]: A list of calldata of the inner calls.
  ///
  /// Returns the Uint8List of the calldata.
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

  /// Returns a ContractFunction instance for a given method.
  ///
  /// - [methodName]: The name of the method in the contract.
  /// - [contractAddress]: The address of the contract.
  /// - [abi]: The ABI of the contract.
  ///
  /// Returns a ContractFunction.
  static ContractFunction getContractFunction(
      String methodName, EthereumAddress contractAddress, ContractAbi abi) {
    final instance = DeployedContract(abi, contractAddress);
    return instance.function(methodName);
  }

  /// Returns a UserOperation to approve the spender of the NFT.
  ///
  /// - [contractAddress]: The address of the contract.
  /// - [owner]: The address of the owner of the NFT.
  /// - [spender]: The address of the spender of the NFT.
  static UserOperation nftApproveOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender, BigInt tokenId) {
    final innerCallData = execute(owner,
        to: contractAddress,
        innerCallData: encodeERC721ApproveCall(
          contractAddress,
          spender,
          tokenId,
        ));
    return UserOperation.partial(callData: hexlify(innerCallData));
  }

  /// Returns a UserOperation to transfer an NFT.
  ///
  /// - [contractAddress]: The address of the contract.
  /// - [owner]: The address of the owner of the NFT.
  /// - [recipient]: The address of the recipient of the NFT.
  static UserOperation nftTransferOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress recipient, BigInt tokenId) {
    final innerCallData = execute(owner,
        to: contractAddress,
        innerCallData: encodeERC721SafeTransferCall(
          contractAddress,
          owner,
          recipient,
          tokenId,
        ));
    return UserOperation.partial(callData: hexlify(innerCallData));
  }

  /// Returns the UserOperation for an ERC20 approval.
  ///
  /// - [contractAddress]: The 4337 wallet address.
  /// - [owner]: The address of the approved owner.
  /// - [spender]: The address of the approved spender.
  /// - [amount]: The amount to approve for the spender.
  ///
  /// Returns the UserOperation.
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
    return UserOperation.partial(callData: hexlify(callData));
  }

  /// Returns the UserOperation for an ERC20 transfer.
  ///
  /// - [contractAddress]: The 4337 wallet address.
  /// - [owner]: The address of the sender.
  /// - [recipient]: The address of the recipient.
  /// - [amount]: The amount to transfer.
  ///
  /// Returns the UserOperation.
  static UserOperation tokenTransferOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress recipient, EtherAmount amount) {
    final callData = execute(owner,
        to: contractAddress,
        innerCallData:
            encodeERC20TransferCall(contractAddress, recipient, amount));
    return UserOperation.partial(callData: hexlify(callData));
  }
}
