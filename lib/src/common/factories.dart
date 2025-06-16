part of '../../variance_dart.dart';

/// A class that extends [LightAccountFactory] and implements [LightAccountFactoryBase].
/// It creates an instance of [LightAccountFactory] with a custom [RPCBase] client.
/// Used to create instances of [SmartWallet] for light accounts.
class _LightAccountFactory extends LightAccountFactory
    implements LightAccountFactoryBase {
  /// Creates a new instance of [_LightAccountFactory].
  ///
  /// [address] is the address of the light account factory.
  /// [chainId] is the ID of the blockchain chain.
  /// [rpc] is the [RPCBase] client used for communication with the blockchain.
  _LightAccountFactory({
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

  /// Predicts the address of the Safe Smart Account based on the initializer data, salt, and creation code.
  ///
  /// [initializer] is the initializer data for deploying the Safe contract.
  /// [salt] is the salt value used for address calculation.
  /// [creationCode] is the creation code for deploying the Safe contract.
  /// [singleton] is the address of the Safe singleton.
  ///
  /// Returns the predicted [Address] of the Safe contract.

  Address getPredictedSafe(
    Uint8List initializer,
    Uint256 salt,
    Uint8List creationCode,
    Address singleton,
  ) {
    final deploymentData = creationCode.concat(
      singleton.value.padLeftTo32Bytes(),
    );

    // toHex pads to 64 then tobytes ensures its always 32 bytes salt
    final create2Salt = keccak256(
      keccak256(initializer).concat(hexToBytes(salt.toHex())),
    );

    final hash = keccak256(
      Uint8List.fromList([0xff])
          .concat(self.address.value)
          .concat(create2Salt)
          .concat(keccak256(deploymentData)),
    );

    return Address(Uint8List.fromList(hash.skip(12).take(20).toList()));
  }

  /// Returns the proxy creation code without making a network request
  @override
  Future<Uint8List> proxyCreationCode({BlockNum? atBlock}) async {
    return hexToBytes(
      "0x608060405234801561001057600080fd5b506040516101e63803806101e68339818101604052602081101561003357600080fd5b8101908080519060200190929190505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614156100ca576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260228152602001806101c46022913960400191505060405180910390fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055505060ab806101196000396000f3fe608060405273ffffffffffffffffffffffffffffffffffffffff600054167fa619486e0000000000000000000000000000000000000000000000000000000060003514156050578060005260206000f35b3660008037600080366000845af43d6000803e60008114156070573d6000fd5b3d6000f3fea264697066735822122003d1488ee65e08fa41e58e888a9865554c535f2c77126a82cb4c0f917f31441364736f6c63430007060033496e76616c69642073696e676c65746f6e20616464726573732070726f7669646564",
    );
  }
}
