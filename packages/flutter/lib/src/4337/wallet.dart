library pks_4337_sdk;

import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/chains.dart';
import 'package:pks_4337_sdk/src/4337/modules/base.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/erc20.dart';
import 'package:pks_4337_sdk/src/4337/modules/erc721.dart';
import 'package:pks_4337_sdk/src/4337/modules/transfers.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:pks_4337_sdk/src/abi/accountFactory.g.dart';
import 'package:pks_4337_sdk/src/abi/entrypoint.g.dart';
import 'package:web3dart/crypto.dart';
import "package:web3dart/web3dart.dart";

class Wallet extends Signer with Modules {
  // [PROVIDERS]
  final BaseProvider _baseProvider;
  final BundlerProvider _walletProvider;
  final IChain _walletChain;

  // [WALLET_ADDRESS]
  EthereumAddress _walletAddress;
  String toHex() => _walletAddress.hexEip55;

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
    _initializeModules(_baseProvider);
  }

  // [GETTERS]
  Address get address => Address.fromEthAddress(_walletAddress,
      ethRpc: _walletChain.rpcUrl, ens: true);
  Future<EtherAmount> get balance =>
      module("contract").getBalance(_walletAddress);
  BaseProvider get baseProvider => _baseProvider;
  Future<bool> get deployed => module("contract").deployed(_walletAddress);
  Future<Uint256> get nonce => _nonce();
  IChain get walletChain => _walletChain;
  BundlerProvider get walletProvider => _walletProvider;

  Uint8List? _initCode;

  /// [create] -> creates a new wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
  create(Uint256 salt, {int? index, String? accountId}) async {
    require(defaultSigner == SignerType.hdkeys && hdkey != null,
        "Create: HD Key instance is required!");
    EthereumAddress owner = EthereumAddress.fromHex(
        await hdkey!.getAddress(index ?? 0, id: accountId));
    AccountFactory factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_baseProvider),
        chainId: _walletChain.chainId);
    _initCode = _initData(factory, 'createAccount', [owner.hex, salt.value]);
    factory
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
    require(defaultSigner == SignerType.passkeys && passkey != null,
        "Create P256: PassKey instance is required!");
    AccountFactory factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_baseProvider),
        chainId: _walletChain.chainId);

    _initCode = _initData(factory, 'createPasskeyAccount',
        [credentialHex, x.value, y.value, salt.value]);
    factory
        .getPasskeyAccountAddress(credentialHex, x.value, y.value, salt.value)
        .then((value) => {_walletAddress = value});
  }

  // TODO: START

  Future send(EthereumAddress recipient, EtherAmount amount) async {
    // sends out native tokens via syntactic sugar
  }

  Future sendTransaction() async {
    // signs the transaction and sends via syntactic sugar
  }

  Future sendBatchedTransaction() async {
    // sends multiple transactions via syntactic sugar
  }

  Future buildUserOperation() async {
    // creates a user operation from syntactic sugar
  }

  Future sendUserOperation() async {
    // signs and sends a signed user operation
  }

  Future signUserOperation(UserOperation op) async {
    // appends a valid signature to a user operation
  }

  Future sendSignedUserOperation(UserOperation op) async {
    // assumes operation has been signed
  }

  // TODO: END

  Uint8List _initData(AccountFactory factory, String name, List params) {
    final data = factory.self.function(name).encodeCall(params);
    final initCode =
        abi.encode(['address', 'bytes'], [factory.self.address, data]);
    return initCode;
  }

  Future<BigInt> _initDataGas() {
    return baseProvider.estimateGas(walletChain.entrypoint,
        bytesToHex(_initCode ?? Uint8List(0), include0x: true));
  }

  Uint8List _callData(
      {EthereumAddress? to, EtherAmount? amount, Uint8List? innerCallData}) {
    return Contract.encodeFunctionCall(
      'execute',
      _walletAddress,
      ContractAbis.get('SimpleAccount'),
      [to ?? _walletAddress, amount ?? EtherAmount.zero(), innerCallData],
    );
  }

  /// initializes the [Wallet] modules
  /// you can still override the default modules by setting yours.
  /// - nft module
  /// - token module
  /// - contract module
  /// - transfers module
  _initializeModules(BaseProvider provider) {
    setModule('erc721', ERC721(provider.rpcUrl));
    setModule('erc20', ERC20(provider));
    setModule('transfers', Transfers(provider));
    setModule('contract', Contract(provider));
  }

  Future<Uint256> _nonce() async {
    return module("contract")
        .call<BigInt>(
            _walletAddress, ContractAbis.get('SimpleAccount'), "getNonce")
        .then((value) => Uint256(value[0]));
  }

  /// creates a [Wallet] instance, additionally initializes the [Entrypoint] contract
  /// use [Wallet.init] directly when you:
  /// - need to interact with the entrypoint.
  /// - want to [wait] for user Operation Events.
  /// - recovering account.
  static Wallet init(IChain chain,
      {HDkeysInterface? hdkey,
      PasskeysInterface? passkey,
      SignerType signer = SignerType.hdkeys,
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
