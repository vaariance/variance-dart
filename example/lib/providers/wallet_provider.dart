import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3dart/web3dart.dart';

import '../models/wallet_creation_result.dart';

enum WalletCreationState {
  idle,
  loading,
  success,
  error,
}

class WalletProvider extends ChangeNotifier {
  // Chain configuration
  final Chain _chain;

  // Wallet instance
  SmartWallet? _wallet;
  SmartWallet? get wallet => _wallet;

  // State management
  WalletCreationState _creationState = WalletCreationState.idle;
  WalletCreationState get creationState => _creationState;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  // Contract addresses
  final EthereumAddress nft = EthereumAddress.fromHex("0x3661b40C520a273214d281bd84730BA68604d874");
  final EthereumAddress erc20 = EthereumAddress.fromHex("0x69583ED4AA579fdc83FB6CCF13A5Ffd9B39F62aF");
  final EthereumAddress deployer = EthereumAddress.fromHex("0xf5bb7f874d8e3f41821175c0aa9910d30d10e193");
  final EthereumAddress p256Verifier = EthereumAddress.fromHex("0xc2b78104907F722DABAc4C69f826a522B2754De4");

  // Common parameters
  final salt = Uint256.zero;
  static var rpc = dotenv.env['BUNDLER_URL']!;

  // Constructor
  WalletProvider() : _chain = Chains.getChain(Network.baseTestnet) {
    _initializeChain();
  }

  // Initialize chain configuration
  void _initializeChain() {
    _chain
      ..accountFactory = Addresses.safeProxyFactoryAddress
      ..bundlerUrl = rpc
      ..paymasterUrl = rpc
      ..jsonRpcUrl = rpc
      ..testnet = true;
  }

  // Set loading state
  void _setLoading() {
    _errorMessage = "";
    _creationState = WalletCreationState.loading;
    notifyListeners();
  }

  // Set success state
  void _setSuccess() {
    _creationState = WalletCreationState.success;
    notifyListeners();
  }

  // Set error state
  void _setError(String message) {
    _errorMessage = message;
    _creationState = WalletCreationState.error;
    notifyListeners();
  }

  // Reset state
  void resetState() {
    _errorMessage = "";
    _creationState = WalletCreationState.idle;
    notifyListeners();
  }

  // Create wallet with passkey
  Future<WalletCreationResult> registerWithPassKey(
      String name, {
        bool? requiresUserVerification
      }) async {
    _setLoading();

    try {
      final options = PassKeysOptions(
        name: "variance",
        namespace: "variance.space",
        authenticatorAttachment: "cross-platform",
        sharedWebauthnSigner: Addresses.sharedSignerAddress,
      );
      final pkpSigner = PassKeySigner(options: options);

      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, pkpSigner);
      final keypair = await pkpSigner.register(
          "${DateTime.timestamp().millisecondsSinceEpoch}@variance.space",
          name
      );

      _wallet = await walletFactory.createSafeAccountWithPasskey(
          keypair,
          salt,
          p256Verifier: p256Verifier
      );

      overrideGas();
      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Create EOA wallet for light account
  Future<WalletCreationResult> createEOAWallet() async {
    _setLoading();

    try {
      _chain.accountFactory = Addresses.lightAccountFactoryAddressv07;

      final signer = EOAWallet.createWallet(
          WordLength.word_12,
          const SignatureOptions(prefix: [0])
      );
      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

      _wallet = await walletFactory.createAlchemyLightAccount(salt);
      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Create EOA wallet for safe account
  Future<WalletCreationResult> createSafeEOAWallet() async {
    _setLoading();

    try {
      _chain.accountFactory = Addresses.lightAccountFactoryAddressv07;

      final signer = EOAWallet.createWallet(
          WordLength.word_12,
          const SignatureOptions(prefix: [0])
      );
      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

      _wallet = await walletFactory.createSafeAccount(salt);
      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Create private key wallet for light account
  Future<WalletCreationResult> createPrivateKeyWallet() async {
    _setLoading();

    try {
      _chain.accountFactory = Addresses.lightAccountFactoryAddressv07;

      final signer = PrivateKeySigner.createRandom(
          "password",
          const SignatureOptions(prefix: [0])
      );
      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

      _wallet = await walletFactory.createAlchemyLightAccount(salt);
      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Create private key wallet for safe account
  Future<WalletCreationResult> createSafePrivateKeyWallet() async {
    _setLoading();

    try {
      _chain.accountFactory = Addresses.lightAccountFactoryAddressv07;

      final signer = PrivateKeySigner.createRandom(
          "password",
          const SignatureOptions(prefix: [0])
      );
      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

      _wallet = await walletFactory.createSafeAccount(salt);
      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Create default safe wallet
  Future<WalletCreationResult> createSafeWallet() async {
    _setLoading();

    try {
      final signer = EOAWallet.createWallet();
      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

      _wallet = await walletFactory.createSafeAccount(salt);
      overrideGas();
      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Create Safe7579 wallet
  Future<WalletCreationResult> createSafe7579Wallet() async {
    _setLoading();

    try {
      final signer = EOAWallet.createWallet();
      final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

      _wallet = await walletFactory.createSafe7579Account(
          salt,
          EthereumAddress.fromHex("0x4bb6ea91bc1257876301e16424cdd215bb73b225"),
          attesters: [
            EthereumAddress.fromHex("0x000000333034E9f539ce08819E12c1b8Cb29084d")
          ],
          validators: [
            ModuleInit(
                EthereumAddress.fromHex("0x2483DA3A338895199E5e538530213157e931Bf06"),
                Uint8List(64)
            )
          ],
          attestersThreshold: 1
      );

      log("Wallet created: ${_wallet?.address.hex}");
      _setSuccess();

      return WalletCreationResult(
        success: true,
        wallet: _wallet,
        address: _wallet?.address.hex ?? '',
      );
    } catch (e) {
      _setError(e.toString());
      log("Error creating wallet: $e");
      return WalletCreationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Send transaction
  Future<(bool, String)> sendTransaction(String recipient, String amount) async {
    try {
      final etherAmount = EtherAmount.fromBigInt(
          EtherUnit.wei,
          BigInt.from(double.parse(amount) * math.pow(10, 18))
      );

      final response = await _wallet?.send(
          EthereumAddress.fromHex(recipient),
          etherAmount
      );
      final receipt = await response?.wait();

      final txHash = receipt?.userOpHash ?? '';
      log("Transaction receipt Hash: $txHash");
      return (true, txHash);
    } catch (e) {
      _setError(e.toString());
      return (false, '');
    }
  }

  // Mint NFT
  Future<(bool, String)> mintNFT() async {
    try {
      // Simple tx
      final tx1 = await _wallet?.sendTransaction(
          nft,
          Contract.encodeFunctionCall(
              "safeMint",
              nft,
              ContractAbis.get("ERC721_SafeMint"),
              [_wallet?.address]
          )
      );
      final receipt1 = await tx1?.wait();

      // Batch tx
      final tx2 = await _wallet?.sendBatchedTransaction(
          [erc20, erc20],
          [
            Contract.encodeFunctionCall(
                "mint",
                erc20,
                ContractAbis.get("ERC20_Mint"),
                [
                  _wallet?.address,
                  EtherAmount.fromInt(EtherUnit.ether, 20).getInWei
                ]
            ),
            Contract.encodeERC20TransferCall(
                erc20,
                deployer,
                EtherAmount.fromInt(EtherUnit.ether, 20)
            )
          ]
      );

      final receipt2 = await tx2?.wait();

      // Return the hash of the most recent transaction
      final txHash = receipt2?.userOpHash ?? receipt1?.userOpHash ?? '';
      log("Transaction receipt Hash: $txHash");

      return (true, txHash);
    } catch (e) {
      _setError(e.toString());
      return (false, '');
    }
  }
  // Override gas
  void overrideGas() {
    // @dev use only when using contract verifier,
    // do not use this function with precompiles.
    // for the safe deployment transaction do not use the multiplier
    // multiply verification gas until it exceeds 400k gas
    _wallet?.gasOverride = GasSettings(
        verificationGasMultiplierPercentage: 650, // 7.5x higher than base - about 410k. adjust if needed
        userDefinedMaxFeePerGas: BigInt.from(24500000000),
        userDefinedMaxPriorityFeePerGas: BigInt.from(12300000000)
    );
  }
}