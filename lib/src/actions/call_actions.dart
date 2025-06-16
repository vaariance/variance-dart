part of '../../variance_dart.dart';

/// A stateless mixin that provides smart wallet call action functionality.
///
/// This mixin contains methods for encoding various smart wallet operations including:
/// - Batch execution of multiple operations
/// - Single operation execution
/// - ERC-20 token operations (approve, transfer)
/// - ERC-721 NFT operations (approve, transfer)
///
/// It is designed to work with the [SmartWalletBase] class and provides core
/// functionality for interacting with smart contract wallets on the blockchain.
mixin _CallActions on SmartWalletBase {
  /// Encodes a function call to execute a batch of operations in a smart wallet.
  ///
  /// Parameters:
  ///   - `recipients`: A list of [Address] instances representing the recipients for each operation.
  ///   - `amountsInWei`: Optional list of [BigInt] instances representing the amounts to transfer for each operation.
  ///   - `innerCalls`: Optional list of [Uint8List] instances containing inner call data for each operation.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'executeBatch' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = executeBatch(
  ///   recipients: [
  ///     Address.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///     Address.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   ],
  ///   amounts: [BigInt.zero, BigInt.from(1000000000000000000)],
  ///   innerCalls: [
  ///     Uint8List.fromList([...]),
  ///     Uint8List(0),
  ///   ],
  /// ); // first call contains call to 0x1234567890abcdef1234567890abcdef12345678 with 0 wei, second call contains call to 0xabcdef1234567890abcdef1234567890abcdef12 with 1000000000000000000 wei
  /// ```
  /// This method uses the 'executeBatch' function ABI to encode the smart wallet batch operation.
  Uint8List getExecuteBatchCalldata({
    required List<Address> recipients,
    List<BigInt>? amountsInWei,
    List<Uint8List>? innerCalls,
  }) {
    List params = [
      recipients,
      amountsInWei ?? recipients.map<BigInt>((e) => BigInt.zero).toList(),
      innerCalls ?? Uint8List(0),
    ];

    if (innerCalls == null || innerCalls.isEmpty) {
      require(
        amountsInWei != null && amountsInWei.isNotEmpty,
        "malformed batch request",
      );
    }

    String method = 'executeBatch';

    if (state.safe != null) {
      method = 'executeUserOpWithErrorString';
      params = [
        Addresses.safeMultiSendaddress,
        BigInt.zero,
        state.safe?.module.getSafeMultisendCallData(
          recipients,
          amountsInWei,
          innerCalls,
        ),
        BigInt.one,
      ];
    }

    return Contract.encodeFunctionCall(
      method,
      address,
      ContractAbis.get(method),
      params,
    );
  }

  /// Encodes a function call to execute a user operation in a smart wallet.
  ///
  /// Parameters:
  ///   - `to`: The [Address] of the target recipient for the operation.
  ///   - `amountInWei`: The [BigInt] representing the amount to transfer, if applicable.
  ///   - `innerCallData`: The [Uint8List] containing inner call data, if applicable.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded data for the 'execute' function call.
  ///
  /// Example:
  /// ```dart
  /// var encodedCall = execute(
  ///   to: Address.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   amountInWei: BigInt.from(1000000000000000000),
  ///   innerCallData: Uint8List(0),
  /// ); // transfer to 0x1234567890abcdef1234567890abcdef12345678 with 1000000000000000000 wei
  /// ```
  /// This method uses the 'execute' function ABI to encode the smart wallet operation.
  Uint8List getExecuteCalldata({
    required Address to,
    BigInt? amountInWei,
    Uint8List? innerCallData,
  }) {
    final params = [
      to,
      amountInWei ?? BigInt.zero,
      innerCallData ?? Uint8List(0),
    ];

    String method = 'execute';

    if (state.safe != null) {
      method = 'executeUserOpWithErrorString';
      params.add(BigInt.zero);
    }

    return Contract.encodeFunctionCall(
      method,
      address,
      ContractAbis.get(method),
      params,
    );
  }

  /// Generates a user operation for approving the transfer of an ERC-721 token.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [Address] of the ERC-721 token contract.
  ///   - `spender`: The [Address] of the address to grant approval.
  ///   - `tokenId`: The [BigInt] representing the ID of the token to approve.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-721 token approval operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = nftApproveUserOperation(
  ///   Address.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   Address.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(123),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC721ApproveCall' to create a user operation.
  UserOperation getNftApproveUserOperation(
    Address contractAddress,
    Address spender,
    BigInt tokenId,
  ) {
    final innerCallData = getExecuteCalldata(
      to: contractAddress,
      innerCallData: Contract.encodeERC721ApproveCall(
        contractAddress,
        spender,
        tokenId,
      ),
    );
    return UserOperation.partial(callData: innerCallData);
  }

  /// Generates a user operation for transferring an ERC-721 token.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [Address] of the ERC-721 token contract.
  ///   - `recipient`: The [Address] of the recipient to receive the token.
  ///   - `tokenId`: The [BigInt] representing the ID of the token to transfer.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-721 token transfer operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = nftTransferUserOperation(
  ///   Address.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   Address.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(123),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC721SafeTransferCall' to create a user operation.
  UserOperation getNftTransferUserOperation(
    Address contractAddress,
    Address recipient,
    BigInt tokenId,
  ) {
    final innerCallData = getExecuteCalldata(
      to: contractAddress,
      innerCallData: Contract.encodeERC721SafeTransferFromCall(
        contractAddress,
        address,
        recipient,
        tokenId,
      ),
    );
    return UserOperation.partial(callData: innerCallData);
  }

  /// Generates a user operation for approving the transfer of ERC-20 tokens.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [Address] of the ERC-20 token contract.
  ///   - `spender`: The [Address] of the address to grant approval.
  ///   - `amountInWei`: The [BigInt] representing the amount to approve.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-20 token approval operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = tokenApproveUserOperation(
  ///   Address.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   Address.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(1000000000000000000),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC20ApproveCall' to create a user operation.
  UserOperation getTokenApproveUserOperation(
    Address contractAddress,
    Address spender,
    BigInt amountInWei,
  ) {
    final callData = getExecuteCalldata(
      to: contractAddress,
      innerCallData: Contract.encodeERC20ApproveCall(
        contractAddress,
        spender,
        amountInWei,
      ),
    );
    return UserOperation.partial(callData: callData);
  }

  /// Generates a user operation for transferring ERC-20 tokens.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [Address] of the ERC-20 token contract.
  ///   - `recipient`: The [Address] of the recipient to receive the tokens.
  ///   - `amountInWei`: The [BigInt] representing the amount of tokens to transfer.
  ///
  /// Returns:
  ///   A [UserOperation] instance for the ERC-20 token transfer operation.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = tokenTransferUserOperation(
  ///   Address.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   Address.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   BigInt.from(1000000000000000000),
  /// );
  /// ```
  /// This method combines the 'execute' function and 'encodeERC20TransferCall' to create a user operation.
  UserOperation getTokenTransferUserOperation(
    Address contractAddress,
    Address recipient,
    BigInt amountInWei,
  ) {
    final callData = getExecuteCalldata(
      to: contractAddress,
      innerCallData: Contract.encodeERC20TransferCall(
        contractAddress,
        recipient,
        amountInWei,
      ),
    );
    return UserOperation.partial(callData: callData);
  }

  @override
  Future<List<dynamic>> readContract(
    Address contractAddress,
    ContractAbi abi,
    String methodName, {
    List<dynamic>? params,
    Address? sender,
  }) {
    final function = Contract.getContractFunction(
      methodName,
      contractAddress,
      abi,
    );
    final calldata = {
      'to': contractAddress.with0x,
      'data': bytesToHex(
        function.encodeCall(params ?? []),
        include0x: true,
        padToEvenLength: true,
      ),
      if (sender != null) 'from': sender.with0x,
    };
    return state.jsonRpc
        .send<String>('eth_call', [calldata, BlockNum.current().toBlockParam()])
        .then((value) => function.decodeReturnValues(value));
  }

  Future<Uint8List> getUserOperationHash(
    UserOperation op,
    BlockInfo blockInfo,
  ) async {
    return state.safe != null
        ? state.safe?.module.getSafeOperationHash(op, blockInfo)
        : op.hash(chain);
  }

  Future<String Function(BlockInfo)> Function(
    Future<T> Function(T, {int? index}),
    int? index,
  )
  _getUserOperationSignHandler<T extends Uint8List>(
    Future<T> Function() getHash,
  ) {
    return (Future<T> Function(T, {int? index}) sign, int? index) async {
      final hash = await getHash();
      final signature = await sign(hash);
      final signatureHex = hexlify(signature);
      return (BlockInfo blockInfo) =>
          state.safe != null
              ? state.safe?.module.getSafeSignature(signatureHex, blockInfo)
                  as String
              : signatureHex;
    };
  }
}
