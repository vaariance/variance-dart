library pks_4337_sdk;

import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/chains.dart';
import 'package:pks_4337_sdk/src/4337/modules/base.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/erc20.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/erc721.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/transfers.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:pks_4337_sdk/src/abi/accountFactory.g.dart';
import 'package:pks_4337_sdk/src/abi/entrypoint.g.dart';
import 'package:pks_4337_sdk/src/signer/passkey_types.dart';
import "package:web3dart/web3dart.dart";

class Wallet extends Signer with Modules {
  // [PROVIDERS]
  final BaseProvider _baseProvider;
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
      super.signer,
      EthereumAddress? address})
      : _walletChain = chain.validate(),
        _walletProvider = BundlerProvider(chain),
        _baseProvider = BaseProvider(chain.rpcUrl!),
        _walletAddress = address ?? Chains.zeroAddress {
    _initialize();
  }

  // [GETTERS]
  Address get address => Address.fromEthAddress(_walletAddress,
      ethRpc: _walletChain.rpcUrl, ens: true);
  Future<EtherAmount> get balance =>
      module("contract").getBalance(_walletAddress);
  BaseProvider get baseProvider => _baseProvider;
  Future<bool> get deployed => module("contract").deployed(_walletAddress);
  Future<Uint256> get nonce => _nonce();
  String get toHex => _walletAddress.hexEip55;
  IChain get walletChain => _walletChain;
  BundlerProvider get walletProvider => _walletProvider;

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

  /// [create] -> creates a new wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
  create(Uint256 salt, {int? index, String? accountId}) async {
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

  /// [createPasskeyAccount] -> creates a new Passkey wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
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

  Future<BigInt> initCodeGas() {
    require(_initCode != null, "No init code");
    return baseProvider.estimateGas(walletChain.entrypoint, _initCode!);
  }

  Future<UserOperationResponse> send(
      EthereumAddress recipient, EtherAmount amount) async {
    return sendUserOperation(buildUserOperation(
        callData(_walletAddress, to: recipient, amount: amount)));
  }

  Future<UserOperationResponse> sendBatchedTransaction(
      List<EthereumAddress> recipients, List<Uint8List> calls,
      {List<EtherAmount>? amounts}) async {
    return sendUserOperation(buildUserOperation(callDataBatched(
        walletAddress: _walletAddress,
        recipients: recipients,
        amounts: amounts,
        innerCalls: calls)));
  }

  Future<UserOperationResponse> sendTransaction(
      EthereumAddress to, Uint8List encodedFunctionData,
      {EtherAmount? amount}) async {
    return sendUserOperation(buildUserOperation(callData(_walletAddress,
        to: to, amount: amount, innerCallData: encodedFunctionData)));
  }

  Future<UserOperationResponse> sendSignedUserOperation(
      UserOperation op) async {
    return _walletProvider.sendUserOperation(
        op.toMap(), _walletChain.entrypoint);
  }

  Future<UserOperationResponse> sendUserOperation(UserOperation op,
      {String id = ""}) async {
    return signUserOperation(op, id: id).then(sendSignedUserOperation);
  }

  Future<UserOperation> signUserOperation(UserOperation userOp,
      {bool update = true, String? id}) async {
    if (update) await _updateUserOperation(userOp);
    final opHash = userOp.hash(_walletChain);
    Uint8List signature;
    if (defaultSigner == SignerType.passkey) {
      signature = (await sign<PassKeySignature>(opHash, id: id)).toHex();
    } else {
      signature = await sign<Uint8List>(opHash, index: 0, id: id);
    }
    userOp.signature = hexlify(signature);
    await _validateFields(userOp);
    return userOp;
  }

  _initialize() {
    _initializeModules();
    _factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_baseProvider),
        chainId: _walletChain.chainId);
  }

  /// initializes the [Wallet] modules
  /// you can still override the default modules by setting yours.
  /// - nft module
  /// - token module
  /// - contract module
  /// - transfers module
  _initializeModules() {
    setModule('erc721', ERC721(_baseProvider.rpcUrl));
    setModule('erc20', ERC20(_baseProvider));
    setModule('transfers', Transfers(_baseProvider));
    setModule('contract', Contract(_baseProvider));
  }

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

  Future _updateUserOperation(UserOperation op) async {
    final map = op.toMap();
    op = await _walletProvider
        .estimateUserOperationGas(map, _walletChain.entrypoint)
        .then((opGas) async => UserOperation.update(map, opGas,
            sender: _walletAddress,
            nonce: (await nonce).value,
            initCode: !(await deployed) ? _initCode! : null));
    await _baseProvider.getGasPrice().then((gasPrice) => {
          op.maxFeePerGas = gasPrice["maxFeePerGas"] as BigInt,
          op.maxPriorityFeePerGas = gasPrice["maxPriorityFeePerGas"] as BigInt,
        });
  }

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

  static Uint8List callData(EthereumAddress walletAddress,
      {required EthereumAddress to,
      EtherAmount? amount,
      Uint8List? innerCallData}) {
    final params = [
      to,
      amount ?? EtherAmount.zero().getInWei,
    ];
    if (innerCallData != null && innerCallData.isNotEmpty) {
      params.add(innerCallData);
    }
    return Contract.encodeFunctionCall(
      'execute',
      walletAddress,
      ContractAbis.get('execute'),
      params,
    );
  }

  static Uint8List callDataBatched(
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
    return Contract.encodeFunctionCall(
      'executeBatch',
      walletAddress,
      ContractAbis.get('executeBatch'),
      params,
    );
  }

  static Uint8List initData(AccountFactory factory, String name, List params) {
    final data = factory.self.function(name).encodeCall(params);
    final initCode =
        abi.encode(['address', 'bytes'], [factory.self.address, data]);
    return initCode;
  }

  /// creates a [Wallet] instance, additionally initializes the [Entrypoint] contract
  /// use [Wallet.init] directly when you:
  /// - need to interact with the entrypoint.
  /// - want to [wait] for user Operation Events.
  /// - recovering account.
  static Wallet init(IChain chain,
      {HDkeysInterface? hdkey,
      PasskeysInterface? passkey,
      SignerType signer = SignerType.hdkey,
      EthereumAddress? address}) {
    final instance = Wallet(
        chain: chain,
        hdkey: hdkey,
        passkey: passkey,
        signer: signer,
        address: address);
    final custom = Web3Client.custom(instance.baseProvider);
    instance._walletProvider.initializeWithEntrypoint(
        Entrypoint(
          address: chain.entrypoint,
          client: custom,
        ),
        custom);
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
