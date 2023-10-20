library pks_4337_sdk;

import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:pks_4337_sdk/src/abi/accountFactory.g.dart';
import 'package:pks_4337_sdk/src/abi/entrypoint.g.dart';
import 'package:pks_4337_sdk/src/modules/alchemy_api/alchemy_api.dart';
import 'package:pks_4337_sdk/src/modules/base.dart';
import 'package:pks_4337_sdk/src/signer/passkey_types.dart';
import "package:web3dart/web3dart.dart";

class Wallet extends Signer with Modules {
  // [PROVIDERS]
  late final BaseProvider _client;
  final BundlerProvider _walletProvider;
  final IChain _walletChain;

  late final AccountFactory _factory;

  // [WALLET_ADDRESS]
  EthereumAddress _walletAddress;
  String? _initCode;

  /// [Entrypoint] is not initialized
  /// to initialize with entrypoint, you have to call [Wallet.init] instead
  ///
  /// Creates an instance of [Wallet]
  Wallet(
      {required IChain chain,
      super.hdkey,
      super.passkey,
      super.credential,
      super.signer,
      EthereumAddress? address})
      : _walletChain = chain.validate(),
        _walletProvider = BundlerProvider(chain),
        _walletAddress = address ?? Chains.zeroAddress {
    _initialize();
  }

  // [GETTERS]
  Address get address => Address.fromEthAddress(_walletAddress,
      ethRpc: _walletChain.rpcUrl, ens: true);
  Future<EtherAmount> get balance =>
      module("contract").getBalance(_walletAddress);
  BaseProvider get baseProvider => _client;
  Future<bool> get deployed => module("contract").deployed(_walletAddress);
  Future<Uint256> get nonce => _nonce();
  String get toHex => _walletAddress.hexEip55;
  IChain get walletChain => _walletChain;
  BundlerProvider get walletProvider => _walletProvider;

  /// [buildUserOperation] builds a [UserOperation]
  /// - @param required [callData] is the [Uint8List] calldata
  /// - @param optional [customNonce] is a custom nonce
  /// - @param optional [callGasLimit] is the call gas limit
  /// - @param optional [verificationGasLimit] is the verification gas limit
  /// - @param optional [preVerificationGas] is the pre verification gas
  /// - @param optional [maxFeePerGas] is the max fee per gas
  /// - @param optional [maxPriorityFeePerGas] is the max priority fee per gas
  /// returns a [UserOperation]
  UserOperation buildUserOperation(
    Uint8List callData, {
    BigInt? customNonce,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) {
    return UserOperation.partial(
      hexlify(callData),
      sender: _walletAddress,
      nonce: customNonce,
      callGasLimit: callGasLimit,
      verificationGasLimit: verificationGasLimit,
      preVerificationGas: preVerificationGas,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
    );
  }

  /// [createAccount] creates a new wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
  ///
  /// - @param required [salt] is the salt for the wallet
  /// - @param optional [index] is the index of the wallet
  /// - @param optional [accountId] is the accountId of the wallet
  createAccount(Uint256 salt, {int? index, String? accountId}) async {
    require(defaultSigner == SignerType.hdkey && hdkey != null,
        "Create: HD Key instance is required!");
    EthereumAddress owner = EthereumAddress.fromHex(
        await hdkey!.getAddress(index ?? 0, id: accountId));
    _initCode =
        hexlify(initData(_factory, 'createAccount', [owner.hex, salt.value]));
    _factory
        .getAddress(owner, salt.value)
        .then((value) => {_walletAddress = value});
  }

  /// [createPasskeyAccount] creates a new Passkey wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
  /// - @param required [credentialHex] is the [Uint8List] hex of the credentialId
  /// - @param required [x] is the x coordinate of the public key
  /// - @param required [y] is the y coordinate of the public key
  /// - @param required [salt] is the salt for create2
  createPasskeyAccount(
      Uint8List credentialHex, Uint256 x, Uint256 y, Uint256 salt) async {
    require(defaultSigner == SignerType.passkey && passkey != null,
        "Create: PassKey instance is required!");
    _initCode = hexlify(initData(_factory, 'createPasskeyAccount',
        [credentialHex, x.value, y.value, salt.value]));
    _factory
        .getPasskeyAccountAddress(credentialHex, x.value, y.value, salt.value)
        .then((value) => {
              _walletAddress = value,
            });
  }

  ///[initCodeGas] is the gas required to deploy the wallet
  Future<BigInt> initCodeGas() {
    require(_initCode != null, "No init code");
    return baseProvider.estimateGas(walletChain.entrypoint, _initCode!);
  }

  /// [initCode] is the init code for the [AccountFactory]
  /// - @param required walletAddress is the address of the wallet
  /// - @param required [name] is the name of the account factory
  /// - @param required [params] is the params of the account factory
  ///
  /// returns the init code for the [AccountFactory]
  Uint8List initData(AccountFactory factory, String name, List params) {
    final data = factory.self.function(name).encodeCall(params);
    final initCode =
        abi.encode(['address', 'bytes'], [factory.self.address, data]);
    return initCode;
  }

  /// initializes the default [Wallet] modules
  /// you can still call your custom method to set it.
  /// - nft module (default alchemyapi)
  /// - token module (default alchemyapi)
  /// - transfers module (default alchemyapi)
  void initializeDefaultModules() {
    setModule('nfts', AlchemyNftApi(_walletChain.rpcUrl!));
    setModule('tokens', AlchemyTokenApi(_client));
    setModule('transfers', AlchemyTransferApi(_client));
  }

  /// [send] transfers native tokens to another recipient
  /// - @param required [recipient] is the address of the user to send the transaction to
  /// - @param required [amount] is the amount to send
  ///
  /// returns the [UserOperationResponse] of the transaction
  Future<UserOperationResponse> send(
      EthereumAddress recipient, EtherAmount amount) async {
    return sendUserOperation(buildUserOperation(
        Contract.execute(_walletAddress, to: recipient, amount: amount)));
  }

  /// [sendBatched] sends a batched transaction to the wallet
  /// - @param required [recipients] is the address of the user to send the transaction to
  /// - @param required [calls] is the calldata to send
  /// - @param required [amounts] is the amounts to send
  ///
  /// returns the [UserOperationResponse] of the transaction
  Future<UserOperationResponse> sendBatchedTransaction(
      List<EthereumAddress> recipients, List<Uint8List> calls,
      {List<EtherAmount>? amounts}) async {
    return sendUserOperation(buildUserOperation(Contract.executeBatch(
        walletAddress: _walletAddress,
        recipients: recipients,
        amounts: amounts,
        innerCalls: calls)));
  }

  /// [sendTransaction] sends a transaction to the wallet
  /// - @param required [to] is the address of the user to send the transaction to
  /// - @param required [encodedFunctionData] is the calldata to send
  /// - @param optional [amount] is the amount to send
  ///
  /// returns the [UserOperationResponse] of the transaction
  Future<UserOperationResponse> sendTransaction(
      EthereumAddress to, Uint8List encodedFunctionData,
      {EtherAmount? amount}) async {
    return sendUserOperation(buildUserOperation(Contract.execute(_walletAddress,
        to: to, amount: amount, innerCallData: encodedFunctionData)));
  }

  /// [sendSignedUserOperation] sends a signed transaction to the wallet
  /// - @param required [op] is the [UserOperation]
  ///
  /// returns the [UserOperationResponse] of the transaction
  Future<UserOperationResponse> sendSignedUserOperation(
      UserOperation op) async {
    return _walletProvider.sendUserOperation(
        op.toMap(), _walletChain.entrypoint);
  }

  /// [sendUserOperation] sends a user operation to the wallet
  /// - @param required [op] is the [UserOperation]
  /// - @param optional [id] is the id of the transaction
  /// returns [signUserOperation] of [UserOperationResponse] and sends a signed transaction when the future completes
  Future<UserOperationResponse> sendUserOperation(UserOperation op,
      {String id = ""}) async {
    return signUserOperation(op, id: id).then(sendSignedUserOperation);
  }

  /// [signUserOperation] signs a user operation using the provided key
  /// - @param required [userOp] is the [UserOperation]
  /// - @param optional [id] is the id of the transaction
  /// - @param optional [update] is true if you want to update the user operation
  ///
  /// returns a signed [UserOperation]
  Future<UserOperation> signUserOperation(UserOperation userOp,
      {bool update = true, String? id}) async {
    if (update) await _updateUserOperation(userOp);
    final opHash = userOp.hash(_walletChain);
    Uint8List signature;
    if (defaultSigner == SignerType.passkey) {
      signature = (await sign<PassKeySignature>(opHash, id: id)).toHex();
    } else if (defaultSigner == SignerType.hdkey) {
      signature = await sign<Uint8List>(opHash, index: 0, id: id);
    } else {
      signature = await sign<Uint8List>(opHash);
    }
    userOp.signature = hexlify(signature);
    await _validateFields(userOp);
    return userOp;
  }

  _initialize() {
    _client = _walletProvider.client;
    _factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_walletProvider.client),
        chainId: _walletChain.chainId);
    setModule('contract', Contract(_walletProvider.client));
  }

  /// [nonce] returns the nonce of the wallet
  Future<Uint256> _nonce() async {
    try {
      return module("contract")
          .call<BigInt>(
              _walletAddress, ContractAbis.get('getNonce'), "getNonce")
          .then((value) => Uint256(value[0]));
    } catch (e) {
      return Uint256(BigInt.zero);
    }
  }

  /// [updateUserOperation] updates the user operation
  /// - @param required [op] is the [UserOperation]
  Future _updateUserOperation(UserOperation op) async {
    final map = op.toMap();
    List<dynamic> reponses = await Future.wait([
      _walletProvider.estimateUserOperationGas(map, _walletChain.entrypoint),
      _client.getGasPrice(),
      nonce,
      deployed
    ]);
    op = UserOperation.update(map, reponses[0],
        sender: _walletAddress,
        nonce: reponses[2].value,
        initCode: !(reponses[3]) ? _initCode! : null);
    op.maxFeePerGas = reponses[1]["maxFeePerGas"] as BigInt;
    op.maxPriorityFeePerGas = reponses[1]["maxPriorityFeePerGas"] as BigInt;
  }

  /// [validateFields] validates the fields of the user operation
  /// - @param required [op] is the [UserOperation]
  _validateFields(UserOperation op) async {
    require(op.sender == _walletAddress && op.sender != Chains.zeroAddress,
        "Operation sender error. ${op.sender} provided.");
    require(op.initCode == ((await deployed) ? "0x" : _initCode!),
        "Init code mismatch");
    require(op.callGasLimit >= BigInt.from(35000),
        "Call gas limit too small expected 35000+");
    require(op.verificationGasLimit >= BigInt.from(70000),
        "Verification gas limit too small expected 70000+");
    require(op.preVerificationGas >= BigInt.from(21000),
        "Pre verification gas too small expected 21000+");
    require(op.callData.length >= 4, "Call data too short, min 4 bytes");
    require(op.signature.length >= 64, "Signature too short, min 64 bytes");
  }

  /// creates a [Wallet] instance, additionally initializes the [Entrypoint] contract
  /// use [Wallet.init] directly when you:
  /// - need to interact with the entrypoint.
  /// - want to [wait] for user Operation Events.
  /// - recovering account.
  static Wallet init(IChain chain,
      {HDkeyInterface? hdkey,
      PasskeyInterface? passkey,
      SignerType signer = SignerType.hdkey,
      EthereumAddress? address}) {
    final instance = Wallet(
        chain: chain,
        hdkey: hdkey,
        passkey: passkey,
        signer: signer,
        address: address);
    instance._walletProvider.initializeWithEntrypoint(Entrypoint(
      address: chain.entrypoint,
      client: instance._factory.client,
    ));
    return instance;
  }
}

// Future userOptester() async {
//   final uop = UserOperation(
//     "0x3AcF7270a4e8D1d1b0656aA76E50C28a40446e77",
//     BigInt.from(2),
//     '0x',
//     '0xb61d27f60000000000000000000000003acf7270a4e8d1d1b0656aa76e50c28a40446e77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000004b0d691fe00000000000000000000000000000000000000000000000000000000',
//     BigInt.from(55000),
//     BigInt.from(80000),
//     BigInt.from(51000),
//     BigInt.zero,
//     BigInt.zero,
//     '0x065f98b3a6250d7a2ba16af1d9cd70e7399dfdd43a59b066fad919c0b0091d8a0ae13b9ee0dc11576f89fb86becac6febf1ea859cb5dad5f3aac3d024eb77f681c',
//     '0x',
//   ).toMap();

//   final etp = await walletProvider.getUserOpReceipt(
//       "0x968330a7d22692ee1214512ee474de65ff00d246440978de87e5740d09d2d354");
//   log("etp: ${etp.toString()}");
//   // walletProvider.sendUserOperation(et, entryPoint)
// }
