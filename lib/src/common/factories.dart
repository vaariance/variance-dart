part of '../../variance.dart';

class _P256AccountFactory extends P256AccountFactory
    implements P256AccountFactoryBase {
  _P256AccountFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));
}

class _SafeProxyFactory extends SafeProxyFactory
    implements SafeProxyFactoryBase {
  _SafeProxyFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));

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

  EthereumAddress getPredictedSafe(
      Uint8List initializer, Uint256 salt, Uint8List creationCode) {
    final deploymentData = Uint8List.fromList(
      [...creationCode, ...Constants.safeSingletonAddress.addressBytes],
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
