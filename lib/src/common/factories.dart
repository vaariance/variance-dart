part of '../../variance.dart';

class _P256AccountFactory extends P256AccountFactory
    implements P256AccountFactoryBase {
  _P256AccountFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));
}

class _SafeProxyFactory extends SafeProxyFactory
    implements SafeProxyFactoryBase {
  final EthereumAddress safe4337ModuleAddress =
      EthereumAddress.fromHex("0xa581c4A4DB7175302464fF3C06380BC3270b4037");
  final EthereumAddress safeSingletonAddress =
      EthereumAddress.fromHex("0x41675C099F32341bf84BFc5382aF534df5C7461a");
  final EthereumAddress safeModuleSetupAddress =
      EthereumAddress.fromHex("0x8EcD4ec46D4D2a6B64fE960B3D64e8B94B2234eb");

  _SafeProxyFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));

  Uint8List getInitializer(EthereumAddress owner) {
    return Contract.encodeFunctionCall(
        "setup", safeSingletonAddress, ContractAbis.get("setup"), [
      [owner],
      BigInt.one,
      safeModuleSetupAddress,
      Contract.encodeFunctionCall("enableModules", safeModuleSetupAddress,
          ContractAbis.get("enableModules"), [
        [safe4337ModuleAddress]
      ]),
      safe4337ModuleAddress,
      Constants.zeroAddress,
      BigInt.zero,
      Constants.zeroAddress,
    ]);
  }

  EthereumAddress getPredictedSafe(
      Uint8List initializer, Uint256 salt, Uint8List creationCode) {
    final deploymentData = Uint8List.fromList(
      [...creationCode, ...safeSingletonAddress.addressBytes],
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

class _SimpleAccountFactory extends SimpleAccountFactory
    implements SimpleAccountFactoryBase {
  _SimpleAccountFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));
}
