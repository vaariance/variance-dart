part of 'interfaces.dart';

/// An abstract class representing the base structure of a Smart Wallet.
///
/// The SmartWalletBase class defines the common structure and methods that
/// a Smart Wallet implementation should have. This allows for flexibility in
/// creating different implementations of Smart Wallets while adhering to a
/// common interface.
abstract class SmartWalletBase extends TransactionService {
  @override
  Address get address;

  /// Returns the balance of the Smart Wallet.
  ///
  /// The balance is retrieved by interacting with the 'contract' plugin.
  Future<BigInt> get balance;

  /// Returns the current chain information of the account
  Chain get chain;

  /// Retrieves the dummy signature required for gas estimation from the Smart Wallet.
  @protected
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

  /// Returns the internal state of the wallet
  @protected
  SmartWalletState get state;

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

  /// Returns the nonce for the Smart Wallet address.
  ///
  /// If the wallet is not deployed, returns 0.
  /// Otherwise, retrieves the nonce by calling the 'getNonce' function on the entrypoint.
  ///
  /// If an error occurs during the nonce retrieval process, a [NonceError] exception is thrown.
  Future<Uint256> getNonce([Uint256? key]);

  /// Prepares a user operation by updating it with the latest nonce and gas prices,
  ///
  /// - [op] is the user operation to prepare.
  /// - [update] is a flag indicating whether to update the user operation with the
  /// latest nonce and gas prices. Defaults to `true`.
  ///
  /// Returns a [Future] that resolves to the prepared [UserOperation] object.
  Future<UserOperation> prepareUserOperation(UserOperation op);

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
  Future<UserOperationResponse> sendUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  });

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

  /// Sponsors a user operation by intercepting it with the paymaster plugin, if present.
  ///
  /// [op] is the user operation to sponsor.
  ///
  /// Returns a [Future] that resolves to the sponsored [UserOperation] object.
  Future<UserOperation> sponsorUserOperation(UserOperation op);

  /// Generates a signature for the given user operation using the specified block information.
  ///
  /// Parameters:
  ///   - `op`: The [UserOperation] to generate a signature for.
  ///   - `blockInfo`: The [BlockInfo] containing current block details needed for signing.
  ///   - `index`: Optional index parameter for selecting a specific signer. Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with the generated signature as a [String].
  ///
  /// Example:
  /// ```dart
  /// var signature = await generateSignature(
  ///   userOperation,
  ///   blockInfo,
  /// );
  /// ```
  Future<String> generateSignature(
    UserOperation op,
    BlockInfo blockInfo,
    int? index,
  );
}

interface class SmartWalletState {
  final Chain chain;

  final Address address;

  final MSI signer;

  final Uint8List initCode;

  final RPCBase jsonRpc;

  final RPCBase bundler;

  final RPCBase? paymaster;

  final Safe? safe;

  /// Optional gas overrides for user operations.
  ///
  /// This can be used to override default gas parameters like maxFeePerGas,
  /// maxPriorityFeePerGas, and callGasLimit when creating user operations.
  GasOverrides? gasOverrides;

  /// The address of the Paymaster contract.
  ///
  /// This is an optional parameter and can be left null if the paymaster address
  /// is not known or needed.
  Address? paymasterAddress;

  /// The context data for the Paymaster.
  ///
  /// This is an optional parameter and can be used to provide additional context
  /// information to the Paymaster when sponsoring user operations.
  Map<String, String>? paymasterContext;

  SmartWalletState({
    required this.chain,
    required this.address,
    required this.signer,
    required this.initCode,
    required this.jsonRpc,
    required this.bundler,
    this.paymaster,
    this.safe,
    this.gasOverrides,
    this.paymasterAddress,
    this.paymasterContext,
  });

  SmartWalletState copyWith({MSI? signer}) {
    return SmartWalletState(
      signer: signer ?? this.signer,
      chain: chain,
      address: address,
      initCode: initCode,
      jsonRpc: jsonRpc,
      bundler: bundler,
      paymaster: paymaster,
      safe: safe,
      gasOverrides: gasOverrides,
      paymasterAddress: paymasterAddress,
      paymasterContext: paymasterContext,
    );
  }
}

abstract class TransactionService {
  /// The Ethereum address of the Smart Wallet.
  Address get address;

  /// Asynchronously calls a function on a smart contract with the provided parameters.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [Address] of the smart contract.
  ///   - `abi`: The [ContractAbi] representing the smart contract's ABI.
  ///   - `methodName`: The name of the method to call on the smart contract.
  ///   - `params`: Optional parameters for the function call.
  ///   - `sender`: The [Address] of the sender, if applicable.
  ///
  /// Returns:
  ///   A [Future] that completes with a list of dynamic values representing the result of the function call.
  ///
  /// Example:
  /// ```dart
  /// var result = await read(
  ///   Address.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   myErc20ContractAbi,
  ///   'balanceOf',
  ///   params: [ Address.fromHex('0x9876543210abcdef9876543210abcdef98765432')],
  /// );
  /// ```
  /// This method uses the an Ethereum jsonRPC to `staticcall` a function on the specified smart contract.
  /// **Note:** This method does not support contract calls with state changes.
  Future<List<dynamic>> readContract(
    Address contractAddress,
    ContractAbi abi,
    String methodName, {
    List<dynamic>? params,
    Address? sender,
  });

  /// Asynchronously transfers native Token (ETH) or an ERC20 Token to the specified recipient with the given amount.
  ///
  /// Parameters:
  ///   - `recipient`: The [Address] of the transaction recipient.
  ///   - `amountInWei`: The [BigInt] representing the amount to be sent in the transaction.
  ///   - `token`: Optional [Address] for an `ERC20` token contract.
  ///   - `nonceKey`: Optional [Uint256] representing the nonce key for the transaction. Defaults to the nonce from bundler.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the transaction.
  ///
  /// Example:
  /// ```dart
  /// var response = await send(
  ///   Address.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   BigInt.from(1000000000000000000),
  /// );
  /// ```
  /// This method internally builds a [UserOperation] using the provided parameters and sends the user operation
  /// using [sendUserOperation], returning the response.
  Future<UserOperationResponse> send(
    Address recipient,
    BigInt amountInWei, {
    Address? token,
    Uint256? nonceKey,
  });

  /// Asynchronously sends an Ethereum transaction to the specified address with the provided encoded function data and optional amount.
  ///
  /// Parameters:
  ///   - `to`: The [Address] of the transaction recipient.
  ///   - `encodedFunctionData`: The [Uint8List] containing the encoded function data for the transaction.
  ///   - `amountInWei`: Optional [BigInt] representing the amount to be sent in the transaction. Defaults to `null`.
  ///   - `nonceKey`: Optional [Uint256] representing the nonce key for the transaction. Defaults to the nonce from bundler.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the transaction.
  ///
  /// Example:
  /// ```dart
  /// var response = await sendTransaction(
  ///   Address.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   Uint8List(0),
  ///   amountInWei: BigInt.from(1000000000000000000),
  /// ); // tranfers ether to 0x9876543210abcdef9876543210abcdef98765432
  /// ```
  /// This method internally builds a [UserOperation] using the provided parameters and sends the user operation
  /// using [sendUserOperation], returning the response.
  Future<UserOperationResponse> sendTransaction(
    Address to,
    Uint8List encodedFunctionData, {
    BigInt? amountInWei,
    Uint256? nonceKey,
  });

  /// Asynchronously sends a batched Ethereum transaction to multiple recipients with the given calls and optional amounts.
  ///
  /// Parameters:
  ///   - `recipients`: A list of [Address] representing the recipients of the batched transaction.
  ///   - `calls`: A list of [Uint8List] representing the calldata for each transaction in the batch.
  ///   - `amountsInWei`: Optional list of [BigInt] representing the amounts for each transaction. Defaults to `null`.
  ///   - `nonceKey`: Optional [Uint256] representing the nonce key for the batched transaction. Defaults to the nonce from bundler.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the batched transaction.
  ///
  /// Example:
  /// ```dart
  /// var response = await sendBatchedTransaction(
  ///   [
  ///     Address.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///     Address.fromHex('0xabcdef1234567890abcdef1234567890abcdef12'),
  ///   ],
  ///   [
  ///     Contract.execute(_walletAddress, to: recipient1, amount: amount1),
  ///     Contract.execute(_walletAddress, to: recipient2, amount: amount2),
  ///   ],
  ///   amounts: [BigInt.from(1000000000000000000), BigInt.from(500000000000000000)],
  /// );
  /// ```
  /// This method internally builds a [UserOperation] using the provided parameters and sends the user operation
  /// using [sendUserOperation], returning the response.
  Future<UserOperationResponse> sendBatchedTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
    Uint256? nonceKey,
  });
}
