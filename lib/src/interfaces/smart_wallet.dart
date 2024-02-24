part of 'interfaces.dart';

/// An abstract class representing the base structure of a Smart Wallet.
///
/// The SmartWalletBase class defines the common structure and methods that
/// a Smart Wallet implementation should have. This allows for flexibility in
/// creating different implementations of Smart Wallets while adhering to a
/// common interface.
abstract class SmartWalletBase {
  /// The Ethereum address associated with the Smart Wallet.
  EthereumAddress? get address;

  /// Retrieves the balance of the Smart Wallet.
  Future<EtherAmount> get balance;

  /// Checks if the Smart Wallet has been deployed on the blockchain.
  Future<bool> get isDeployed;

  /// Retrieves the init code of the Smart Wallet.
  String? get initCode;

  /// Retrieves the gas required to deploy the Smart Wallet.
  Future<BigInt> get initCodeGas;

  /// Retrieves the nonce of the Smart Wallet.
  Future<Uint256> get nonce;

  /// Converts the Smart Wallet address to its hexadecimal representation.
  String? get toHex;

  /// Sets the smart wallet address for this account;
  set setWalletAddress(EthereumAddress address);

  /// Builds a [UserOperation] instance with the specified parameters.
  ///
  /// Parameters:
  ///   - `callData` (required): The call data as a [Uint8List].
  ///   - `customNonce`: An optional custom nonce value.
  ///   - `callGasLimit`: An optional custom call gas limit as a [BigInt].
  ///   - `verificationGasLimit`: An optional custom verification gas limit as a [BigInt].
  ///   - `preVerificationGas`: An optional custom pre-verification gas as a [BigInt].
  ///   - `maxFeePerGas`: An optional custom maximum fee per gas as a [BigInt].
  ///   - `maxPriorityFeePerGas`: An optional custom maximum priority fee per gas as a [BigInt].
  ///
  /// Returns:
  ///   A [UserOperation] instance with the specified parameters.
  ///
  /// Example:
  /// ```dart
  /// var userOperation = buildUserOperation(
  ///   callData: Uint8List(0xabcdef),
  ///   customNonce: BigInt.from(42),
  ///   callGasLimit: BigInt.from(20000000),
  ///   // Other optional parameters can be provided as needed.
  /// );
  /// ```
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  });

  /// Sets the account initialization calldata for a [SmartWalletBase] in a potentially unsafe manner.
  ///
  /// **Warning:**
  /// This method allows setting the initialization calldata directly, which may lead to unexpected behavior
  /// if used improperly. It is intended for advanced use cases where the caller is aware of the potential risks.
  ///
  /// Parameters:
  ///   - `code`: The initialization calldata as a [Uint8List]. Set to `null` to clear the existing data.
  ///
  /// Example:
  /// ```dart
  /// dangerouslySetInitCallData(Uint8List.fromList([0x01, 0x02, 0x03]));
  /// ```
  void dangerouslySetInitCallData(Uint8List? code);

  /// Asynchronously creates a simple Ethereum smart account using the provided salt value.
  /// Uses counterfactactual deployment to create the account and [isDeployed] should be used to check deployment status.
  /// An `initCode` will be attached on the first transaction.
  ///
  /// Parameters:
  ///   - `salt`: A [Uint256] representing the salt value for account creation.
  ///   - `index`: Optional parameter specifying the index for selecting a signer. Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with the created [SmartWallet] instance.
  ///
  /// Example:
  /// ```dart
  /// var smartWallet = await createSimpleAccount(Uint256.zero, index: 1);
  /// ```
  /// This method generates initialization calldata using the 'createAccount' method and the provided signer and salt.
  /// It then retrieves the Ethereum address for the simple account and sets it to the wallet instance.
  Future createSimpleAccount(Uint256 salt, {int? index});

  /// Asynchronously creates a simple Ethereum smart account using a passkey pair and the provided salt value.
  ///
  /// Parameters:
  ///   - `pkp`: A [PassKeyPair] representing the passkey pair for account creation.
  ///   - `salt`: A [Uint256] representing the salt value for account creation.
  ///
  /// Returns:
  ///   A [Future] that completes with the created [SmartWallet] instance.
  ///
  /// Example:
  /// ```dart
  /// var smartWallet = await createSimplePasskeyAccount(myPassKeyPair, Uint256.zero);
  /// ```
  /// This method generates initialization calldata using the 'createPasskeyAccount' method and the provided
  /// passkey pair and salt. The passkey pair includes the credential and public key values.
  Future createSimplePasskeyAccount(PassKeyPair pkp, Uint256 salt);

  /// Asynchronously retrieves the Ethereum address for a simple account created with the specified signer and salt.
  ///
  /// Parameters:
  ///   - `signer`: The [EthereumAddress] of the signer associated with the account.
  ///   - `salt`: A [Uint256] representing the salt value used in the account creation.
  ///
  /// Returns:
  ///   A [Future] that completes with the Ethereum address of the simple account.
  ///
  /// Example:
  /// ```dart
  /// var address = await getSimpleAccountAddress(
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   Uint256.zero,
  /// );
  /// ```
  Future<EthereumAddress> getSimpleAccountAddress(
      EthereumAddress signer, Uint256 salt);

  /// Asynchronously retrieves the Ethereum address for a simple account created with the specified passkey pair and salt.
  ///
  /// Parameters:
  ///   - `pkp`: The [PassKeyPair] used for creating the account.
  ///   - `salt`: A [Uint256] representing the salt value used in the account creation.
  ///
  /// Returns:
  ///   A [Future] that completes with the Ethereum address of the simple account.
  ///
  /// Example:
  /// ```dart
  /// var address = await getSimplePassKeyAccountAddress(
  ///   myPassKeyPair,
  ///   Uint256.zero,
  /// );
  /// ```
  Future<EthereumAddress> getSimplePassKeyAccountAddress(
      PassKeyPair pkp, Uint256 salt);

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
  ///   - `id`: Optional identifier (credential Id) when using a passkey signer Defaults to `null`.
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
  Future<UserOperation> signUserOperation(
    UserOperation userOp, {
    bool update = true,
    String? id,
  });
}
