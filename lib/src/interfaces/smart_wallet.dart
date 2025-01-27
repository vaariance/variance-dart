part of 'interfaces.dart';

enum SmartWalletType {
  Vendor,
  LightAccount,
  Safe,
  Safe7579,
  // Safe7702,
  SafeWithPasskey;
}

/// An abstract class representing the base structure of a Smart Wallet.
///
/// The SmartWalletBase class defines the common structure and methods that
/// a Smart Wallet implementation should have. This allows for flexibility in
/// creating different implementations of Smart Wallets while adhering to a
/// common interface.
abstract class SmartWalletBase {
  /// The Ethereum address of the Smart Wallet.
  EthereumAddress get address;

  /// Returns the balance of the Smart Wallet.
  ///
  /// The balance is retrieved by interacting with the 'contract' plugin.
  Future<EtherAmount> get balance;

  /// Retrieves the dummy signature required for gas estimation from the Smart Wallet.
  String get dummySignature;

  /// Returns the initialization code for deploying the Smart Wallet contract.
  String? get initCode;

  /// Returns the estimated gas required for deploying the Smart Wallet contract.
  ///
  /// The gas estimation is performed by interacting with the 'jsonRpc' plugin.
  Future<BigInt> get initCodeGas;

  /// Checks if the Smart Wallet is deployed on the blockchain.
  ///
  /// The deployment status is checked by interacting with the 'contract' plugin.
  Future<bool> get isDeployed;

  /// Returns the nonce for the Smart Wallet from the entrypoint.
  ///
  /// The nonce is retrieved by calling the `_getNonce` method.
  Future<Uint256> get nonce;

  /// Returns the hexadecimal representation of the Smart Wallet address in EIP-55 format.
  String? get toHex;

  /// Returns the current chain information of the account
  Chain get chain;

  /// Builds a [UserOperation] instance with the specified parameters.
  ///
  /// Parameters:
  ///   - `callData` (required): The call data as a [Uint8List].
  ///   - `customNonce`: An optional custom nonce value.
  ///
  /// Returns:
  ///   A [UserOperation] instance with the specified parameters.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = buildUserOperation(
  ///   callData: Uint8List(0xabcdef),
  ///   customNonce: BigInt.from(42),
  /// );
  /// ```
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
  });

  /// Sets the initialization code for deploying the Smart Wallet contract.
  ///
  /// This method is marked as `@Deprecated` and should not be used in production code.
  /// It is recommended to set the initialization code during the construction of the [SmartWallet] instance.
  ///
  /// **Warning:**
  /// This method allows setting the initialization calldata directly, which may lead to unexpected behavior
  /// if used improperly. It is intended for advanced use cases where the caller is aware of the potential risks.
  ///
  /// Parameters:
  ///   - `code`: The initialization calldata as a [Uint8List].
  ///
  /// Example:
  /// ```dart
  /// dangerouslySetInitCallData(Uint8List.fromList([0x01, 0x02, 0x03]));
  /// ```
  @Deprecated("Not recommended to modify the initcode")
  void dangerouslySetInitCode(Uint8List code);

  /// Prepares a user operation by updating it with the latest nonce and gas prices,
  ///
  /// [op] is the user operation to prepare.
  /// [update] is a flag indicating whether to update the user operation with the
  /// latest nonce and gas prices. Defaults to `true`.
  ///
  /// Returns a [Future] that resolves to the prepared [UserOperation] object.
  Future<UserOperation> prepareUserOperation(UserOperation op,
      {bool update = true});

  /// Sponsors a user operation by intercepting it with the paymaster plugin, if present.
  ///
  /// [op] is the user operation to sponsor.
  ///
  /// Returns a [Future] that resolves to the sponsored [UserOperation] object.
  Future<UserOperation> sponsorUserOperation(UserOperation op);

  /// Asynchronously transfers native Token (ETH) to the specified recipient with the given amount.
  ///
  /// Parameters:
  ///   - `recipient`: The [EthereumAddress] of the transaction recipient.
  ///   - `amount`: The [EtherAmount] representing the amount to be sent in the transaction.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the transaction.
  ///
  /// Example:
  /// ```dart
  /// var response = await send(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   EtherAmount.inWei(BigInt.from(1000000000000000000)),
  /// );
  /// ```
  /// This method internally builds a [UserOperation] using the provided parameters and sends the user operation
  /// using [sendUserOperation], returning the response.
  Future<UserOperationResponse> send(
    EthereumAddress recipient,
    EtherAmount amount,
  );

  /// Asynchronously sends a batched Ethereum transaction to multiple recipients with the given calls and optional amounts.
  ///
  /// Parameters:
  ///   - `recipients`: A list of [EthereumAddress] representing the recipients of the batched transaction.
  ///   - `calls`: A list of [Uint8List] representing the calldata for each transaction in the batch.
  ///   - `amounts`: Optional list of [EtherAmount] representing the amounts for each transaction. Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the batched transaction.
  ///
  /// Example:
  /// ```dart
  /// var response = await sendBatchedTransaction(
  ///   [
  ///     EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///     EthereumAddress.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   ],
  ///   [
  ///     Contract.execute(_walletAddress, to: recipient1, amount: amount1),
  ///     Contract.execute(_walletAddress, to: recipient2, amount: amount2),
  ///   ],
  ///   amounts: [EtherAmount.inWei(BigInt.from(1000000000000000000)), EtherAmount.inWei(BigInt.from(500000000000000000))],
  /// );
  /// ```
  /// This method internally builds a [UserOperation] using the provided parameters and sends the user operation
  /// using [sendUserOperation], returning the response.
  Future<UserOperationResponse> sendBatchedTransaction(
    List<EthereumAddress> recipients,
    List<Uint8List> calls, {
    List<EtherAmount>? amounts,
  });

  /// Asynchronously sends a signed user operation to the bundler for execution.
  ///
  /// Parameters:
  ///   - `op`: The signed [UserOperation] to be sent for execution.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the executed operation.
  ///
  /// Example:
  /// ```dart
  /// var response = await sendSignedUserOperation(mySignedUserOperation);
  /// ```
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op);

  /// Asynchronously sends an Ethereum transaction to the specified address with the provided encoded function data and optional amount.
  ///
  /// Parameters:
  ///   - `to`: The [EthereumAddress] of the transaction recipient.
  ///   - `encodedFunctionData`: The [Uint8List] containing the encoded function data for the transaction.
  ///   - `amount`: Optional [EtherAmount] representing the amount to be sent in the transaction. Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the transaction.
  ///
  /// Example:
  /// ```dart
  /// var response = await sendTransaction(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   Uint8List.fromList([]),
  ///   amount: EtherAmount.inWei(BigInt.from(1000000000000000000)),
  /// ); // tranfers ether to 0x9876543210abcdef9876543210abcdef98765432
  /// ```
  /// This method internally builds a [UserOperation] using the provided parameters and sends the user operation
  /// using [sendUserOperation], returning the response.
  Future<UserOperationResponse> sendTransaction(
    EthereumAddress to,
    Uint8List encodedFunctionData, {
    EtherAmount? amount,
  });

  /// Asynchronously sends a user operation after signing it and obtaining the required signatures.
  ///
  /// Parameters:
  ///   - `op`: The [UserOperation] to be signed and sent.
  ///   - `id`: Optional identifier (credential Id) when using a passkey signer Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the executed operation.
  ///
  /// Example:
  /// ```dart
  /// // when using passkey signer, the credentialId idenfies the credential that is associated with the account.
  /// var response = await sendUserOperation(myUserOperation, id: 'credentialId'); // index is effectively ignored even if provided
  /// ```
  Future<UserOperationResponse> sendUserOperation(UserOperation op);

  /// Asynchronously signs a user operation with the required signatures.
  ///
  /// Parameters:
  ///   - `userOp`: The [UserOperation] to be signed.
  ///   - `update`: Optional parameter indicating whether to update the user operation before signing. Defaults to `true`.
  ///   - `index`: Optional index parameter for selecting a signer. Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with the signed [UserOperation].
  ///
  /// Example:
  /// ```dart
  /// // when using HD wallet, index can be used to specify which privatekey to use
  /// var signedOperation = await signUserOperation(myUserOperation, index: 0); // signer 0
  /// var signedOperation = await signUserOperation(myUserOperation, index: 1); // signer 1
  /// ```
  Future<UserOperation> signUserOperation(UserOperation op, {int? index});
}
