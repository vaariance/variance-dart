import 'package:web3_signers/web3_signers.dart';

/// Class to keep all contract addresses in one place
class Addresses {
  // Factory addresses
  static final safeProxyFactoryAddress = EthereumAddress.fromHex("0xYourSafeProxyFactoryAddress");
  static final lightAccountFactoryAddressv07 = EthereumAddress.fromHex("0xYourLightAccountFactoryAddress");

  // Signer addresses
  static final sharedSignerAddress = EthereumAddress.fromHex("0xYourSharedSignerAddress");

  // Prevent instantiation
  Addresses._();
}