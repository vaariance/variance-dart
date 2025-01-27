part of '../../variance_dart.dart';

Uint8List encode7579LaunchpadInitdata(
    {required EthereumAddress launchpad,
    required Safe4337ModuleAddress module,
    Iterable<ModuleInit>? executors,
    Iterable<ModuleInit>? fallbacks,
    Iterable<ModuleInit>? hooks,
    Iterable<EthereumAddress>? attesters,
    int? attestersThreshold}) {
  return Contract.encodeFunctionCall(
      "initSafe7579", launchpad, ContractAbis.get("initSafe7579"), [
    module.address,
    executors?.map((e) => [e.module, e.initData]).toList() ?? [],
    fallbacks?.map((e) => [e.module, e.initData]).toList() ?? [],
    hooks?.map((e) => [e.module, e.initData]).toList() ?? [],
    attesters?.toList() ?? [],
    BigInt.from(attestersThreshold ?? 0),
  ]);
}

Uint8List get7579InitHash(
    {required Uint8List initData,
    required EthereumAddress launchpad,
    required Iterable<EthereumAddress> owners,
    required int threshold,
    required Safe4337ModuleAddress module,
    required SafeSingletonAddress singleton,
    Iterable<ModuleInit>? validators}) {
  final encodedData = abi.encode([
    "address",
    "address[]",
    "uint256",
    "address",
    "bytes",
    "address",
    "(address,bytes)[]"
  ], [
    singleton.address,
    owners.toList(),
    BigInt.from(threshold),
    launchpad,
    initData,
    module.address,
    validators?.map((e) => [e.module, e.initData]).toList() ?? []
  ]);
  return keccak256(encodedData);
}

Uint8List encode7579InitCalldata(
    {required EthereumAddress launchpad, required Uint8List initHash}) {
  return Contract.encodeFunctionCall(
      "preValidationSetup",
      launchpad,
      ContractAbis.get("preValidationSetup"),
      [initHash, Addresses.zeroAddress, Uint8List(0)]);
}

// Uint8List encodePostSetupInitCalldata(){}
