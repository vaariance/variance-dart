part of '../../variance.dart';

/// A class that extends [P256AccountFactory] and implements [P256AccountFactoryBase].
/// It creates an instance of [P256AccountFactory] with a custom [RPCBase] client.
/// Used to create instances of [SmartWallet] for P256 accounts.
class _P256AccountFactory extends P256AccountFactory
    implements P256AccountFactoryBase {
  /// Creates a new instance of [_P256AccountFactory].
  ///
  /// [address] is the address of the account factory.
  /// [chainId] is the ID of the blockchain chain.
  /// [rpc] is the [RPCBase] client used for communication with the blockchain.
  _P256AccountFactory({
    required super.address,
    super.chainId,
    required RPCBase rpc,
  }) : super(client: Web3Client.custom(rpc));
}

/// A class that extends [SafeProxyFactory] and implements [SafeProxyFactoryBase].
/// It creates an instance of [SafeProxyFactory] with a custom [RPCBase] client.
/// Used to create instances of [SmartWallet] for Safe accounts.
/// Additionally, it provides methods for getting the initializer data and predicting the Safe address.
class _SafeProxyFactory extends SafeProxyFactory
    implements SafeProxyFactoryBase {
  /// Creates a new instance of [_SafeProxyFactory].
  ///
  /// [address] is the address of the Safe proxy factory.
  /// [chainId] is the ID of the blockchain chain.
  /// [rpc] is the [RPCBase] client used for communication with the blockchain.
  _SafeProxyFactory({
    required super.address,
    super.chainId,
    required RPCBase rpc,
  }) : super(client: Web3Client.custom(rpc));

  /// Generates the initializer data for deploying a new Safe contract.
  ///
  /// [owners] is an iterable of owner addresses for the Safe.
  /// [threshold] is the required number of confirmations for executing transactions.
  /// [module] is the address of the Safe module to enable.
  ///
  /// Returns a [Uint8List] containing the encoded initializer data.
  Uint8List getInitializer(Iterable<EthereumAddress> owners, int threshold,
      Safe4337ModuleAddress module) {
    return Contract.encodeFunctionCall(
        "setup", Constants.safeSingletonAddress, ContractAbis.get("setup"), [
      owners.toList(),
      BigInt.from(threshold),
      Constants.safeModuleSetupAddress,
      Contract.encodeFunctionCall("enableModules",
          Constants.safeModuleSetupAddress, ContractAbis.get("enableModules"), [
        [module.address]
      ]),
      module.address,
      Constants.zeroAddress,
      BigInt.zero,
      Constants.zeroAddress,
    ]);
  }

  /// Predicts the address of the Safe Smart Account based on the initializer data, salt, and creation code.
  ///
  /// [initializer] is the initializer data for deploying the Safe contract.
  /// [salt] is the salt value used for address calculation.
  /// [creationCode] is the creation code for deploying the Safe contract.
  ///
  /// Returns the predicted [EthereumAddress] of the Safe contract.

  EthereumAddress getPredictedSafe(
      Uint8List initializer, Uint256 salt, Uint8List creationCode) {
    paddedAddressBytes(Uint8List addressBytes) {
      return [...Uint8List(32 - addressBytes.length), ...addressBytes];
    }

    final deploymentData = Uint8List.fromList(
      [
        ...creationCode,
        ...paddedAddressBytes(Constants.safeSingletonAddress.addressBytes)
      ],
    );

    final hash = keccak256(
      Uint8List.fromList([
        0xff,
        ...self.address.addressBytes,
        ...keccak256(Uint8List.fromList([
          ...keccak256(initializer),
          ...intToBytes(salt.value),
        ])),
        ...keccak256(deploymentData),
      ]),
    );

    final predictedAddress =
        EthereumAddress(Uint8List.fromList(hash.skip(12).take(20).toList()));
    return predictedAddress;
  }
}

/// A class that extends [SimpleAccountFactory] and implements [SimpleAccountFactoryBase].
/// It creates an instance of [SimpleAccountFactory] with a custom [RPCBase] client.
/// Used to create instances of [SmartWallet] for simple accounts.
class _SimpleAccountFactory extends SimpleAccountFactory
    implements SimpleAccountFactoryBase {
  /// Creates a new instance of [_SimpleAccountFactory].
  ///
  /// [address] is the address of the simple account factory.
  /// [chainId] is the ID of the blockchain chain.
  /// [rpc] is the [RPCBase] client used for communication with the blockchain.
  _SimpleAccountFactory({
    required super.address,
    super.chainId,
    required RPCBase rpc,
  }) : super(client: Web3Client.custom(rpc));
}
