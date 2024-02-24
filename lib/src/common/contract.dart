part of 'common.dart';

/// A wrapper for interacting with deployed Ethereum contracts through [RPCProvider].
class Contract {
  final RPCProviderBase _provider;

  Contract(
    this._provider,
  );

  /// Asynchronously calls a function on a smart contract with the provided parameters.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the smart contract.
  ///   - `abi`: The [ContractAbi] representing the smart contract's ABI.
  ///   - `methodName`: The name of the method to call on the smart contract.
  ///   - `params`: Optional parameters for the function call.
  ///   - `sender`: The [EthereumAddress] of the sender, if applicable.
  ///
  /// Returns:
  ///   A [Future] that completes with a list of dynamic values representing the result of the function call.
  ///
  /// Example:
  /// ```dart
  /// var result = await call(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   myErc20ContractAbi,
  ///   'balanceOf',
  ///   params: [ EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432')],
  /// );
  /// ```
  /// This method uses the an Ethereum jsonRPC to `staticcall` a function on the specified smart contract.
  /// **Note:** This method does not support contract calls with state changes.
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
    return _provider.send<String>('eth_call', [
      calldata,
      BlockNum.current().toBlockParam()
    ]).then((value) => function.decodeReturnValues(value));
  }

  /// Asynchronously checks whether a smart contract is deployed at the specified address.
  ///
  /// Parameters:
  ///   - `address`: The [EthereumAddress] of the smart contract.
  ///   - `atBlock`: The [BlockNum] specifying the block to check for deployment. Defaults to the current block.
  ///
  /// Returns:
  ///   A [Future] that completes with a [bool] indicating whether the smart contract is deployed.
  ///
  /// Example:
  /// ```dart
  /// var isDeployed = await deployed(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   atBlock: BlockNum.exact(123456), // optional
  /// );
  /// ```
  /// This method uses an ethereum jsonRPC to check if a smart contract is deployed at the specified address.
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

  /// Asynchronously retrieves the balance of an Ethereum address.
  ///
  /// Parameters:
  ///   - `address`: The [EthereumAddress] for which to retrieve the balance.
  ///   - `atBlock`: The [BlockNum] specifying the block at which to check the balance. Defaults to the current block.
  ///
  /// Returns:
  ///   A [Future] that completes with an [EtherAmount] representing the balance.
  ///
  /// Example:
  /// ```dart
  /// var balance = await getBalance(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   atBlock: BlockNum.exact(123456), // optional
  /// );
  /// ```
  /// This method uses an ethereum jsonRPC to  fetch the balance of the specified Ethereum address.
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

  /// Encodes an ERC-20 token approval function call.
  ///
  /// Parameters:
  ///   - `address`: The [EthereumAddress] of the ERC-20 token contract.
  ///   - `spender`: The [EthereumAddress] of the spender to approve.
  ///   - `amount`: The [EtherAmount] representing the amount to approve in the token's base unit.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'approve' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = encodeERC20ApproveCall(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EtherAmount.inWei(BigInt.from(1000000000000000000)),
  /// );
  /// ```
  /// This method uses the ERC-20 contract ABI to return a `calldata` for 'approve' function call.
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

  /// Encodes an ERC-20 token transfer function call.
  ///
  /// Parameters:
  ///   - `address`: The [EthereumAddress] of the ERC-20 token contract.
  ///   - `recipient`: The [EthereumAddress] of the recipient to receive the tokens.
  ///   - `amount`: The [EtherAmount] representing the amount of tokens to transfer in the token's base unit.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'transfer' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = encodeERC20TransferCall(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EtherAmount.inWei(BigInt.from(1000000000000000000)),
  /// );
  /// ```
  /// This method uses the ERC-20 contract ABI to return a `calldata` for'transfer' function call.
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

  /// Encodes an ERC-721 token approval function call.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the ERC-721 token contract.
  ///   - `to`: The [EthereumAddress] of the address to grant approval.
  ///   - `tokenId`: The [BigInt] representing the ID of the token to approve.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'approve' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = encodeERC721ApproveCall(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   BigInt.from(123),
  /// );
  /// ```
  /// This method uses the ERC-721 contract ABI to return a `calldata` for 'approve' function call.
  static Uint8List encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, BigInt tokenId) {
    return encodeFunctionCall("approve", contractAddress,
        ContractAbis.get("ERC721"), [to.hex, tokenId]);
  }

  /// Encodes an ERC-721 token safe transfer function call.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the ERC-721 token contract.
  ///   - `from`: The [EthereumAddress] of the current owner of the token.
  ///   - `to`: The [EthereumAddress] of the recipient to receive the token.
  ///   - `tokenId`: The [BigInt] representing the ID of the token to transfer.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'safeTransferFrom' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = encodeERC721SafeTransferCall(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(123),
  /// );
  /// ```
  /// This method uses the ERC-721 contract ABI  to return a `calldata` for 'safeTransferFrom' function call.
  static Uint8List encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, BigInt tokenId) {
    return encodeFunctionCall("safeTransferFrom", contractAddress,
        ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId]);
  }

  /// Encodes a function call for a smart contract.
  ///
  /// Parameters:
  ///   - `methodName`: The name of the method to call.
  ///   - `contractAddress`: The [EthereumAddress] of the smart contract.
  ///   - `abi`: The [ContractAbi] representing the smart contract's ABI.
  ///   - `params`: The list of dynamic parameters for the function call.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded calldata for the specified function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = encodeFunctionCall(
  ///   'transfer',
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   ContractAbis.get('ERC20'),
  ///   [EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'), BigInt.from(100)],
  /// );
  /// ```
  /// This method uses the specified ABI to encode the function call for the smart contract.
  static Uint8List encodeFunctionCall(String methodName,
      EthereumAddress contractAddress, ContractAbi abi, List<dynamic> params) {
    final func = getContractFunction(methodName, contractAddress, abi);
    return func.encodeCall(params);
  }

  /// Encodes a function call to execute a user operation in a smart wallet.
  ///
  /// Parameters:
  ///   - `walletAddress`: The [EthereumAddress] of the smart wallet.
  ///   - `to`: The [EthereumAddress] of the target recipient for the operation.
  ///   - `amount`: The [EtherAmount] representing the amount to transfer, if applicable.
  ///   - `innerCallData`: The [Uint8List] containing inner call data, if applicable.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'execute' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = execute(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   to: EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   amount: EtherAmount.inWei(BigInt.from(1000000000000000000)),
  ///   innerCallData: Uint8List.fromList([]),
  /// ); // transfer to 0x1234567890abcdef1234567890abcdef12345678 with 1000000000000000000 wei
  /// ```
  /// This method uses the 'execute' function ABI to encode the smart wallet operation.
  static Uint8List execute(EthereumAddress? walletAddress,
      {required EthereumAddress to,
      EtherAmount? amount,
      Uint8List? innerCallData}) {
    final params = [
      to,
      amount?.getInWei ?? EtherAmount.zero().getInWei,
      innerCallData ?? Uint8List.fromList([])
    ];

    if (walletAddress == null) {
      throw SmartWalletError(
          "Invlaid Operation, SmartWallet Address is undefined! (contract.execute)");
    }

    return encodeFunctionCall(
      'execute',
      walletAddress,
      ContractAbis.get('execute'),
      params,
    );
  }

  /// Encodes a function call to execute a batch of operations in a smart wallet.
  ///
  /// Parameters:
  ///   - `walletAddress`: The [EthereumAddress] of the smart wallet.
  ///   - `recipients`: A list of [EthereumAddress] instances representing the recipients for each operation.
  ///   - `amounts`: Optional list of [EtherAmount] instances representing the amounts to transfer for each operation.
  ///   - `innerCalls`: Optional list of [Uint8List] instances containing inner call data for each operation.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'executeBatch' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = executeBatch(
  ///   walletAddress: EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   recipients: [
  ///     EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///     EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   ],
  ///   amounts: [EtherAmount.zero(), EtherAmount.inWei(BigInt.from(1000000000000000000))],
  ///   innerCalls: [
  ///     Uint8List.fromList([...]),
  ///     Uint8List.fromList([]),
  ///   ],
  /// ); // first call contains call to 0x1234567890abcdef1234567890abcdef12345678 with 0 wei, second call contains call to 0xabcdef1234567890abcdef1234567890abcdef12 with 1000000000000000000 wei
  /// ```
  /// This method uses the 'executeBatch' function ABI to encode the smart wallet batch operation.
  static Uint8List executeBatch(
      {required EthereumAddress? walletAddress,
      required List<EthereumAddress> recipients,
      List<EtherAmount>? amounts,
      List<Uint8List>? innerCalls}) {
    final params = [
      recipients,
      amounts?.map<BigInt>((e) => e.getInWei) ?? [],
      innerCalls ?? Uint8List.fromList([]),
    ];
    if (innerCalls == null || innerCalls.isEmpty) {
      require(amounts != null && amounts.isNotEmpty, "malformed batch request");
    }

    if (walletAddress == null) {
      throw SmartWalletError(
          "Invlaid Operation, SmartWallet Address is undefined! (contract.executeBatch)");
    }

    return encodeFunctionCall(
      'executeBatch',
      walletAddress,
      ContractAbis.get('executeBatch'),
      params,
    );
  }

  /// Retrieves a smart contract function by name from its ABI.
  ///
  /// Parameters:
  ///   - `methodName`: The name of the method to retrieve.
  ///   - `contractAddress`: The [EthereumAddress] of the smart contract.
  ///   - `abi`: The [ContractAbi] representing the smart contract's ABI.
  ///
  /// Returns:
  ///   A [ContractFunction] representing the specified function from the smart contract's ABI.
  ///
  /// Example:
  /// ```dart
  /// var function = getContractFunction(
  ///   'transfer',
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   ContractAbis.get('ERC20'),
  /// );
  /// ```
  /// This method uses the 'function' method of the DeployedContract instance.
  static ContractFunction getContractFunction(
      String methodName, EthereumAddress contractAddress, ContractAbi abi) {
    final instance = DeployedContract(abi, contractAddress);
    return instance.function(methodName);
  }

  /// Generates a user operation for approving the transfer of an ERC-721 token.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the ERC-721 token contract.
  ///   - `owner`: The [EthereumAddress] of the token owner.
  ///   - `spender`: The [EthereumAddress] of the address to grant approval.
  ///   - `tokenId`: The [BigInt] representing the ID of the token to approve.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-721 token approval operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = nftApproveUserOperation(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(123),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC721ApproveCall' to create a user operation.
  static UserOperation nftApproveUserOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender, BigInt tokenId) {
    final innerCallData = execute(owner,
        to: contractAddress,
        innerCallData: encodeERC721ApproveCall(
          contractAddress,
          spender,
          tokenId,
        ));
    return UserOperation.partial(callData: innerCallData);
  }

  /// Generates a user operation for transferring an ERC-721 token.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the ERC-721 token contract.
  ///   - `owner`: The [EthereumAddress] of the current owner of the token.
  ///   - `recipient`: The [EthereumAddress] of the recipient to receive the token.
  ///   - `tokenId`: The [BigInt] representing the ID of the token to transfer.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-721 token transfer operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = nftTransferUserOperation(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(123),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC721SafeTransferCall' to create a user operation.
  static UserOperation nftTransferUserOperation(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress recipient, BigInt tokenId) {
    final innerCallData = execute(owner,
        to: contractAddress,
        innerCallData: encodeERC721SafeTransferCall(
          contractAddress,
          owner,
          recipient,
          tokenId,
        ));
    return UserOperation.partial(callData: innerCallData);
  }

  /// Generates a user operation for approving the transfer of ERC-20 tokens.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the ERC-20 token contract.
  ///   - `owner`: The [EthereumAddress] of the token owner.
  ///   - `spender`: The [EthereumAddress] of the address to grant approval.
  ///   - `amount`: The [EtherAmount] representing the amount to approve.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-20 token approval operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = tokenApproveUserOperation(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   EtherAmount.inWei(BigInt.from(1000000000000000000)),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC20ApproveCall' to create a user operation.
  static UserOperation tokenApproveUserOperation(
    EthereumAddress contractAddress,
    EthereumAddress owner,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    final callData = execute(owner,
        to: contractAddress,
        innerCallData:
            encodeERC20ApproveCall(contractAddress, spender, amount));
    return UserOperation.partial(callData: callData);
  }

  /// Generates a user operation for transferring ERC-20 tokens.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the ERC-20 token contract.
  ///   - `owner`: The [EthereumAddress] of the current owner of the tokens.
  ///   - `recipient`: The [EthereumAddress] of the recipient to receive the tokens.
  ///   - `amount`: The [EtherAmount] representing the amount of tokens to transfer.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-20 token transfer operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = tokenTransferUserOperation(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   EtherAmount.inWei(BigInt.from(1000000000000000000)),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC20TransferCall' to create a user operation.
  static UserOperation tokenTransferUserOperation(
      EthereumAddress contractAddress,
      EthereumAddress owner,
      EthereumAddress recipient,
      EtherAmount amount) {
    final callData = execute(owner,
        to: contractAddress,
        innerCallData:
            encodeERC20TransferCall(contractAddress, recipient, amount));
    return UserOperation.partial(callData: callData);
  }
}
