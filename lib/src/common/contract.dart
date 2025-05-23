part of '../../variance_dart.dart';

class Contract {
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
      ContractAbis.get('ERC20_Approve'),
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
      ContractAbis.get('ERC20_Transfer'),
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
    EthereumAddress contractAddress,
    EthereumAddress to,
    BigInt tokenId,
  ) {
    return encodeFunctionCall(
      "approve",
      contractAddress,
      ContractAbis.get("ERC721_Approve"),
      [to.hex, tokenId],
    );
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
  static Uint8List encodeERC721SafeTransferFromCall(
    EthereumAddress contractAddress,
    EthereumAddress from,
    EthereumAddress to,
    BigInt tokenId,
  ) {
    return encodeFunctionCall(
      "safeTransferFrom",
      contractAddress,
      ContractAbis.get("ERC721_SafeTransferFrom"),
      [from.hex, to.hex, tokenId],
    );
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
  static Uint8List encodeFunctionCall(
    String methodName,
    EthereumAddress contractAddress,
    ContractAbi abi,
    List<dynamic> params,
  ) {
    final func = getContractFunction(methodName, contractAddress, abi);
    return func.encodeCall(params);
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
    String methodName,
    EthereumAddress contractAddress,
    ContractAbi abi,
  ) {
    final instance = DeployedContract(abi, contractAddress);
    return instance.function(methodName);
  }
}
