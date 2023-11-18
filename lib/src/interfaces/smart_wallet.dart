part of 'package:variance_dart/interfaces.dart';

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
  Future<bool> get deployed;

  /// Retrieves the init code of the Smart Wallet.
  String? get initCode;

  /// Retrieves the gas required to deploy the Smart Wallet.
  Future<BigInt> get initCodeGas;

  /// Retrieves the nonce of the Smart Wallet.
  Future<Uint256> get nonce;

  /// Converts the Smart Wallet address to its hexadecimal representation.
  String? get toHex;

  /// Builds a [UserOperation] based on provided parameters.
  ///
  /// This method creates a [UserOperation] with the given call data and optional parameters.
  /// The resulting [UserOperation] can be used for various operations on the Smart Wallet.
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  });

  /// manually Sets the init code of the Smart Wallet and overrides the default.
  void dangerouslySetInitCode(String? code);

  /// Creates a new wallet address using counterfactual deployment.
  ///
  /// This method generates a new wallet address based on the provided salt value.
  /// The wallet may not actually be deployed, and [deployed] should be used to check deployment status.
  /// An `initCode` will be attached on the first transaction.
  ///
  /// - [salt]: The salt for the wallet.
  /// - [index]: The index of the wallet (optional).
  Future createSimpleAccount(Uint256 salt, {int? index});

  /// Creates a new Passkey wallet address using counterfactual deployment.
  ///
  /// This method generates a new Passkey wallet address based on the provided parameters.
  /// The wallet may not actually be deployed, and [deployed] should be used to check deployment status.
  /// An `initCode` will be attached on the first transaction.
  ///
  /// - [pkp]: The PasskeyPair for the wallet passkey signer.
  /// - [salt]: The salt for create2.
  Future createSimplePasskeyAccount(PassKeyPair pkp, Uint256 salt);

  /// Retrieves the counterfactual address of a wallet created with [createAccount].
  Future<Address> getSimpleAccountAddress(EthereumAddress signer, Uint256 salt);

  /// Retrieves the counterfactual address of a Passkey wallet created with [createSimplePasskeyAccount].
  Future<Address> getSimplePassKeyAccountAddress(PassKeyPair pkp, Uint256 salt);

  /// Transfers native tokens to another recipient.
  ///
  /// - [recipient]: The address of the recipient.
  /// - [amount]: The amount to send.
  ///
  /// Returns the [UserOperationResponse] of the transaction.
  Future<UserOperationResponse> send(
    EthereumAddress recipient,
    EtherAmount amount,
  );

  /// Sends a batched transaction to the wallet.
  ///
  /// - [recipients]: The addresses of the recipients.
  /// - [calls]: The calldata to send.
  /// - [amounts]: The amounts to send (optional).
  ///
  /// Returns the [UserOperationResponse] of the transaction.
  Future<UserOperationResponse> sendBatchedTransaction(
    List<EthereumAddress> recipients,
    List<Uint8List> calls, {
    List<EtherAmount>? amounts,
  });

  /// Sends a signed user operation to the bundler.
  ///
  /// - [op]: The [UserOperation].
  ///
  /// Returns the [UserOperationResponse] of the transaction.
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op);

  /// Sends a transaction to the wallet contract.
  ///
  /// - [to]: The address of the recipient.
  /// - [encodedFunctionData]: The calldata to send.
  /// - [amount]: The amount to send (optional).
  ///
  /// Returns the [UserOperationResponse] of the transaction.
  Future<UserOperationResponse> sendTransaction(
    EthereumAddress to,
    Uint8List encodedFunctionData, {
    EtherAmount? amount,
  });

  /// Signs and sends a user operation to the bundler.
  ///
  /// - [op]: The [UserOperation].
  ///
  /// Returns the [UserOperationResponse] of the transaction.
  Future<UserOperationResponse> sendUserOperation(UserOperation op);

  /// Signs a user operation using the provided key.
  ///
  /// - [userOp]: The [UserOperation].
  /// - [update]: True if you want to update the user operation (optional).
  /// - [id]: The id of the transaction (optional).
  ///
  /// Returns a signed [UserOperation].
  Future<UserOperation> signUserOperation(
    UserOperation userOp, {
    bool update = true,
    String? id,
  });
}
