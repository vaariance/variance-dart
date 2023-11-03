library vaariance_dart;

import 'dart:typed_data';
import 'package:vaariance_dart/src/abis/abis.dart';
import 'package:vaariance_dart/src/abis/accountFactory.g.dart';
import 'package:vaariance_dart/src/abis/entrypoint.g.dart';
import 'package:vaariance_dart/src/modules/alchemy_api/alchemy_api.dart';
import 'package:vaariance_dart/src/modules/base.dart';
import 'package:vaariance_dart/vaariance.dart';
import "package:web3dart/web3dart.dart";

class Wallet extends Signer with Modules {
  // [PROVIDERS]
  final BaseProvider _rpcProvider;
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
        _rpcProvider = BaseProvider(chain.rpcUrl!),
        _walletProvider = BundlerProvider(chain),
        _walletAddress = address ?? Chains.zeroAddress {
    _initialize();
  }

  // [GETTERS]
  Address get address => Address.fromEthAddress(_walletAddress,
      ethRpc: _walletChain.rpcUrl,
      ens: _walletAddress == Chains.zeroAddress ? false : true);
  Future<EtherAmount> get balance =>
      module("contract").getBalance(_walletAddress);
  Future<bool> get deployed => module("contract").deployed(_walletAddress);
  Future<Uint256> get nonce => _nonce();
  BaseProvider get rpcProvider => _rpcProvider;
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

  Future<EthereumAddress> getAccountAddress(
      EthereumAddress owner, BigInt salt) async {
    return await _factory.getAddress(owner, salt);
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
  Future createAccount(Uint256 salt, {int? index, String? accountId}) async {
    EthereumAddress owner = await _signerAddress(n: index, id: accountId);
    _initCode =
        hexlify(_initData(_factory, 'createAccount', [owner, salt.value]));
    _walletAddress = await getAccountAddress(owner, salt.value);
  }

  Future<EthereumAddress> getPassKeyAccountAddress(
      Uint8List credentialHex, Uint256 x, Uint256 y, Uint256 salt) async {
    return await _factory.getPasskeyAccountAddress(
        credentialHex, x.value, y.value, salt.value);
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
  Future createPasskeyAccount(
      Uint8List credentialHex, Uint256 x, Uint256 y, Uint256 salt) async {
    require(defaultSigner == SignerType.passkey && passkey != null,
        "Create: PassKey instance is required!");
    _initCode = hexlify(_initData(_factory, 'createPasskeyAccount',
        [credentialHex, x.value, y.value, salt.value]));
    _walletAddress = await getPassKeyAccountAddress(credentialHex, x, y, salt);
  }

  ///[initCodeGas] is the gas required to deploy the wallet
  Future<BigInt> initCodeGas() {
    require(_initCode != null, "No init code");
    return rpcProvider.estimateGas(walletChain.entrypoint, _initCode!);
  }

  /// initializes the default [Wallet] modules
  /// you can still call your custom method to set it.
  /// - nft module (default alchemyapi)
  /// - token module (default alchemyapi)
  /// - transfers module (default alchemyapi)
  void initializeDefaultModules() {
    setModule('nfts', AlchemyNftApi(_walletChain.rpcUrl!));
    setModule('tokens', AlchemyTokenApi(_rpcProvider));
    setModule('transfers', AlchemyTransferApi(_rpcProvider));
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

  /// [_initData] is the init code for the [AccountFactory]
  /// - @param required [name] is the name of the account factory
  /// - @param required [params] is the params of the account factory
  ///
  /// returns the init code for the [AccountFactory]
  Uint8List _initData(AccountFactory factory, String name, List params) {
    final data = factory.self.function(name).encodeCall(params);
    final initCode =
        abi.encode(['address', 'bytes'], [factory.self.address, data]);
    return initCode;
  }

  _initialize() {
    _factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_rpcProvider),
        chainId: _walletChain.chainId);
    setModule('contract', Contract(_rpcProvider));
  }

  /// [nonce] returns the nonce of the wallet
  Future<Uint256> _nonce() async {
    if (_walletAddress.hex == Chains.zeroAddress.hex) {
      return Uint256.zero;
    }
    try {
      return module("contract")
          .call<BigInt>(
              _walletAddress, ContractAbis.get('getNonce'), "getNonce")
          .then((value) => Uint256(value[0]));
    } catch (e) {
      return Uint256.zero;
    }
  }

  Future<EthereumAddress> _signerAddress({int? n, String? id}) async {
    switch (defaultSigner) {
      case SignerType.hdkey:
        require(hdkey != null, "Create: HD Key signer is required!");
        return await hdkey!.getAddress(n ?? 0, id: id);
      case SignerType.credential:
        require(credential != null, "Create: Credential signer is required!");
        return credential!.address;
      default:
        require(false, "Create: Unsupported Signer Type");
        return Chains.zeroAddress;
    }
  }

  /// [updateUserOperation] updates the user operation
  /// - @param required [op] is the [UserOperation]
  Future _updateUserOperation(UserOperation op) async {
    final map = op.toMap();
    List<dynamic> reponses = await Future.wait([
      _walletProvider.estimateUserOperationGas(map, _walletChain.entrypoint),
      _rpcProvider.getGasPrice(),
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
