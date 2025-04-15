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
      "initSafe7579", launchpad, Safe7579Abis.get("initSafe7579"), [
    module.address,
    executors?.map((e) => [e.module, e.initData]).toList() ?? [],
    fallbacks?.map((e) => [e.module, e.initData]).toList() ?? [],
    hooks?.map((e) => [e.module, e.initData]).toList() ?? [],
    attesters?.toList() ?? [],
    BigInt.from(attestersThreshold ?? 0),
  ]);
}

Uint8List get7579InitHash(
    {required Uint8List launchpadInitData,
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
    launchpadInitData,
    module.address,
    validators?.map((e) => [e.module, e.initData]).toList() ?? []
  ]);
  return keccak256(encodedData);
}

Uint8List encode7579InitCalldata(
    {required EthereumAddress launchpad,
    required Uint8List initHash,
    required EthereumAddress setupTo,
    required Uint8List setupData}) {
  return Contract.encodeFunctionCall("preValidationSetup", launchpad,
      Safe7579Abis.get("preValidationSetup"), [initHash, setupTo, setupData]);
}

Uint8List encodeExecutionMode(ExecutionMode executionMode) {
  final typeBytes = intToBytes(BigInt.from(executionMode.type.value));
  final revertOnErrorBytes =
      intToBytes(executionMode.revertOnError ? BigInt.one : BigInt.zero);
  final selectorBytes = (executionMode.selector ?? Uint8List(0)).padToNBytes(4);
  final contextBytes = (executionMode.context ?? Uint8List(0)).padToNBytes(22);

  return typeBytes
      .concat(revertOnErrorBytes)
      .concat(Uint8List(0).padToNBytes(4))
      .concat(selectorBytes)
      .concat(contextBytes);
}

Uint8List encode7579Call(ExecutionMode mode, List<Uint8List> calldata,
    EthereumAddress contractAddress) {
  return Contract.encodeFunctionCall(
      'execute', contractAddress, Safe7579Abis.get('execute7579'), [
    encodeExecutionMode(mode),
    mode.type == CallType.batchcall
        ? encode7579BatchCall(calldata)
        : calldata.first
  ]);
}

Uint8List encode7579BatchCall(List<Uint8List> calldatas) {
  return abi.encode([
    "(address,uint256,bytes)[]"
  ], [
    calldatas
        .map((calldata) => [
              EthereumAddress(calldata.sublist(0, 20)), // address 20 bytes
              bytesToInt(calldata.sublist(20, 52)), // uint256 32 bytes
              calldata.sublist(52) // rest
            ])
        .toList()
  ]);
}

Uint8List _encodePostSetupInitCalldata(_Safe7579Initializer initializer,
    List<Uint8List> calldata, EthereumAddress contractAddress, CallType type) {
  return Contract.encodeFunctionCall(
      "setupSafe", initializer.launchpad, Safe7579Abis.get("setup7579Safe"), [
    [
      initializer.singleton.address,
      initializer.owners.toList(),
      BigInt.from(initializer.threshold),
      initializer.launchpad,
      initializer.getLaunchpadInitData(),
      initializer.module.address,
      initializer.validators?.map((e) => [e.module, e.initData]).toList() ?? [],
      encode7579Call(ExecutionMode(type: type), calldata, contractAddress)
    ]
  ]);
}
