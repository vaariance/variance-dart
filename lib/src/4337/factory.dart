 part of '../../variance.dart'; 

  class SmartWalletFactory implements SmartWalletFactoryBase {

    // createSimpleAccount
    // createP256Account
    // createVendorAccount
    // createSafeAccount
    // _createAccount
    
  }
  
  SmartWallet(
      {required Chain chain,
      required MultiSignerInterface signer,
      @Deprecated(
          "Bundler instance will be constructed by by factory from chain params")
      required BundlerProviderBase bundler,
      @Deprecated("to be removed: address will be made final in the future")
      EthereumAddress? address})
      : _chain = chain.validate(),
        _walletAddress = address {
    // since the wallet factory will use builder pattern to add plugins
    // the following can be moved into the factory.
    // which would allow the smartwallet to reamin testable.
    final jsonRpc = RPCProvider(chain.jsonRpcUrl!);
    final bundlerRpc = RPCProvider(chain.bundlerUrl!);

    final bundler = BundlerProvider(chain, bundlerRpc);
    final fact = _AccountFactory(
        address: chain.accountFactory!, chainId: chain.chainId, rpc: jsonRpc);

    addPlugin('signer', signer);
    addPlugin('bundler', bundler);
    addPlugin('jsonRpc', jsonRpc);
    addPlugin('contract', Contract(jsonRpc));
    addPlugin('factory', fact);

    if (chain.paymasterUrl != null) {
      final paymasterRpc = RPCProvider(chain.paymasterUrl!);
      final paymaster = Paymaster(chain, paymasterRpc);
      addPlugin('paymaster', paymaster);
    }
  }

  /// Initializes a [SmartWallet] instance for a specific chain with the provided parameters.
  ///
  /// Parameters:
  ///   - `chain`: The blockchain [Chain] associated with the smart wallet.
  ///   - `signer`: The [MultiSignerInterface] responsible for signing transactions.
  ///   - `bundler`: The [BundlerProviderBase] that provides bundling services.
  ///   - `address`: Optional Ethereum address associated with the smart wallet.
  ///   - `initCallData`: Optional initialization calldata of the factory create method as a [Uint8List].
  ///
  /// Returns:
  ///   A fully initialized [SmartWallet] instance.
  ///
  /// Example:
  /// ```dart
  /// var smartWallet = SmartWallet.init(
  ///   chain: Chain.ethereum,
  ///   signer: myMultiSigner,
  ///   bundler: myBundler,
  ///   address: myWalletAddress,
  ///   initCallData: Uint8List.fromList([0x01, 0x02, 0x03]),
  /// );
  /// ```
  factory SmartWallet.init(
      {required Chain chain,
      required MultiSignerInterface signer,
      @Deprecated(
          "Bundler instance will be constructed by by factory from chain params")
      required BundlerProviderBase bundler,
      @Deprecated("address will be made final in the future")
      EthereumAddress? address,
      @Deprecated("seperation of factory from wallet soon will be enforced")
      Uint8List? initCallData}) {
    final instance = SmartWallet(
        chain: chain, signer: signer, bundler: bundler, address: address);
    return instance;
  }

@override
Future<SmartWallet> createSimplePasskeyAccount(
    PassKeyPair pkp, Uint256 salt) async {
  _initCalldata = _getInitCallData('createPasskeyAccount', [
    pkp.credentialHexBytes,
    pkp.publicKey[0].value,
    pkp.publicKey[1].value,
    salt.value
  ]);

  await getSimplePassKeyAccountAddress(pkp, salt)
      .then((addr) => {_walletAddress = addr});
  return this;
}

@override
Future<SmartWallet> createSimpleAccount(Uint256 salt, {int? index}) async {
  EthereumAddress signer = EthereumAddress.fromHex(
      plugin<MSI>('signer').getAddress(index: index ?? 0));
  _initCalldata = _getInitCallData('createAccount', [signer, salt.value]);
  await getSimpleAccountAddress(signer, salt)
      .then((addr) => {_walletAddress = addr});
  return this;
}

@override
Future<EthereumAddress> getSimpleAccountAddress(
        EthereumAddress signer, Uint256 salt) =>
    plugin<AccountFactoryBase>('factory').getAddress(signer, salt.value);

@override
Future<EthereumAddress> getSimplePassKeyAccountAddress(
        PassKeyPair pkp, Uint256 salt) =>
    plugin<AccountFactoryBase>('factory').getPasskeyAccountAddress(
        pkp.credentialHexBytes,
        pkp.publicKey[0].value,
        pkp.publicKey[1].value,
        salt.value);

Uint8List _getInitCallData(String functionName, List params) =>
    plugin('factory').self.function(functionName).encodeCall(params);
