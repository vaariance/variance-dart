import 'dart:developer';
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

  bool _isModular = false;
  bool get isModular => _isModular;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  // Contract addresses
  final EthereumAddress nft =
      EthereumAddress.fromHex("0xEBE46f55b40C0875354Ac749893fe45Ce28e1333");
  // fuse = EthereumAddress.fromHex("0xBF20E2bB8bb6859A424C898d5a2995c3659b90f2");
  final EthereumAddress erc20 =
      EthereumAddress.fromHex("0x7BF7957315AFbC9bA717b004BB9E3f43321a9A48");
  // fuse = EthereumAddress.fromHex("0xAc94c8dD3094AB2D68B092AA34A6e29A293E592a");
  final EthereumAddress dump =
      EthereumAddress.fromHex("0xf5bb7f874d8e3f41821175c0aa9910d30d10e193");
  // final EthereumAddress p256Verifier =
  //     EthereumAddress.fromHex("0xc2b78104907F722DABAc4C69f826a522B2754De4");

  // Common parameters
  final salt = Uint256.zero;
  static var rpc = dotenv.env['BUNDLER_URL']!;

  // Constructor
  WalletProvider()
      : _chain = Chain(
            bundlerUrl: rpc,
            paymasterUrl: rpc,
            testnet: true,
            chainId: 84532,
            jsonRpcUrl: "https://sepolia.base.org",
            accountFactory: Addresses.safeProxyFactoryAddress,
            explorer: "https://base-sepolia.blockscout.com/",
            entrypoint: EntryPointAddress.v07);

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

  MSI getSigner(String type,
      [SignatureOptions options = const SignatureOptions()]) {
    switch (type) {
      case 'passkey':
        return PassKeySigner(
            options: PassKeysOptions(
          name: "variance",
          namespace: "variance.space",
          authenticatorAttachment: "platform",
          sharedWebauthnSigner: Addresses.sharedSignerAddress,
        ));
      case 'privateKey':
        return PrivateKeySigner.createRandom(
          "test",
          options,
        );
      case 'EOA':
        return EOAWallet.createWallet(
          WordLength.word_12,
          options,
        );
      default:
        throw Exception('Invalid signer type');
    }
  }

  Future<WalletCreationResult> createSafeWallet(String signerType) async {
    _setLoading();

    final signer = getSigner(signerType);
    final factory = SmartWalletFactory(_chain, signer);

    try {
      switch (signerType) {
        case 'passkey':
          final keypair = await (signer as PassKeySigner).register(
            "${DateTime.timestamp().millisecondsSinceEpoch}@variance.space",
            'variance',
          );
          _wallet = await factory.createSafeAccountWithPasskey(keypair, salt);
          break;
        default:
          _wallet = await factory.createSafeAccount(salt);
          break;
      }
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

  Future<WalletCreationResult> createLightWallet(String signerType) async {
    _setLoading();
    _chain.accountFactory = Addresses.lightAccountFactoryAddressv07;

    final signer = getSigner(signerType, const SignatureOptions(prefix: [0]));
    final factory = SmartWalletFactory(_chain, signer);

    try {
      _wallet = await factory.createAlchemyLightAccount(salt);
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

  Future<WalletCreationResult> createModularWallet(String signerType) async {
    _setLoading();
    final signer = getSigner(signerType);
    final factory = SmartWalletFactory(_chain, signer);
    final launchpad =
        EthereumAddress.fromHex("0x7579011aB74c46090561ea277Ba79D510c6C00ff");
    final attester =
        EthereumAddress.fromHex("0x000000333034E9f539ce08819E12c1b8Cb29084d");

    try {
      switch (signerType) {
        case 'passkey':
          final keypair = await (signer as PassKeySigner).register(
            "${DateTime.timestamp().millisecondsSinceEpoch}@variance.space",
            'variance',
          );
          _wallet = await factory.createSafe7579AccountWithPasskey(
              keypair, salt, launchpad,
              attesters: [attester], attestersThreshold: 1);
          break;
        default:
          _wallet = await factory.createSafe7579Account(salt, launchpad,
              attesters: [attester], attestersThreshold: 1);
          break;
      }
      _isModular = true;
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

  Future<(bool, String)> simulateMint() async {
    final mintAbi = ContractAbis.get("ERC721_SafeMint");
    final mintCall = Contract.encodeFunctionCall(
        "safeMint", nft, mintAbi, [_wallet?.address]);

    try {
      final tx = await _wallet?.sendTransaction(nft, mintCall);
      final receipt = await tx?.wait();
      final txHash = receipt?.txReceipt.transactionHash;
      log("Transaction receipt Hash: $txHash");
      return (true, txHash ?? '');
    } catch (e) {
      final errString = e.toString();
      log(errString);
      return (
        false,
        errString.substring(0, errString.length > 200 ? 200 : null)
      );
    }
  }

  Future<(bool, String)> simulateTransfer() async {
    final mintAbi = ContractAbis.get("ERC20_Mint");
    final amount = EtherAmount.fromInt(EtherUnit.ether, 20);

    final mintCall = Contract.encodeFunctionCall(
        "mint", erc20, mintAbi, [_wallet?.address, amount.getInWei]);
    final transferCall = Contract.encodeERC20TransferCall(erc20, dump, amount);

    try {
      final tx = await _wallet
          ?.sendBatchedTransaction([erc20, erc20], [mintCall, transferCall]);
      final receipt = await tx?.wait();
      final txHash = receipt?.txReceipt.transactionHash;
      log("Transaction receipt Hash: $txHash");
      return (true, txHash ?? '');
    } catch (e) {
      final errString = e.toString();
      log(errString);
      return (
        false,
        errString.substring(0, errString.length > 200 ? 200 : null)
      );
    }
  }

  // Override gas
  void overrideGas() {
    // @dev use only when needed
    _wallet?.gasOverrides = GasOverrides(
      maxPriorityFeePerGas: (p0) => BigInt.from(13600000),
    );
  }
}
