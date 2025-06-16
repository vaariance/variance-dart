part of '../../variance_dart.dart';

/// Packs two 128-bit unsigned integers into a 32-byte array.
///
/// Parameters:
/// - [high128]: The high 128-bit unsigned integer.
/// - [low128]: The low 128-bit unsigned integer.
///
/// Returns a Uint8List containing the packed bytes.
///
/// Example:
/// ```dart
/// final high128 = BigInt.from(1);
/// final low128 = BigInt.from(2);
/// final packedBytes = packUints(high128, low128);
/// print(packedBytes);
/// ```
Uint8List packUints(BigInt high128, BigInt low128) {
  final packed = (high128 << 128) + low128;
  return hexToBytes('0x${packed.toRadixString(16).padLeft(64, '0')}');
}

/// Unpacks two 128-bit unsigned integers from a 32-byte array.
///
/// Parameters:
/// - [bytes]: The 32-byte array containing the packed bytes.
///
/// Returns a list containing the unpacked high and low 128-bit unsigned integers.
///
/// Example:
/// ```dart
/// final unpacked = unpackUints("0x...32byteshex");
/// print(unpacked);
/// ```
List<BigInt> unpackUints(String hex) {
  final value = BigInt.parse(hex.substring(2), radix: 16);
  return [value >> 128, value.toUnsigned(128)];
}

/// Encodes initialization data for a Safe7579 launchpad.
///
/// Parameters:
/// - [launchpad]: The Ethereum address of the launchpad contract
/// - [module]: The Safe 4337 module address
/// - [executors]: Optional list of executor module initializations
/// - [fallbacks]: Optional list of fallback module initializations
/// - [hooks]: Optional list of hook module initializations
/// - [attesters]: Optional list of attester addresses
/// - [attestersThreshold]: Optional threshold for attesters
///
/// Returns encoded initialization data as a Uint8List.
Uint8List encode7579LaunchpadInitdata({
  required Address launchpad,
  required Safe4337ModuleAddress module,
  Iterable<ModuleInit>? executors,
  Iterable<ModuleInit>? fallbacks,
  Iterable<ModuleInit>? hooks,
  Iterable<Address>? attesters,
  int? attestersThreshold,
}) {
  return Contract.encodeFunctionCall(
    "initSafe7579",
    launchpad,
    Safe7579Abis.get("initSafe7579"),
    [
      module.address,
      executors?.map((e) => [e.module, e.initData]).toList() ?? [],
      fallbacks?.map((e) => [e.module, e.initData]).toList() ?? [],
      hooks?.map((e) => [e.module, e.initData]).toList() ?? [],
      attesters?.toList() ?? [],
      BigInt.from(attestersThreshold ?? 0),
    ],
  );
}

/// Calculates the initialization hash for a Safe7579 setup. this hash is stored after inidata is stored on safe during entrypoint intidata call. to be referenced later during calldata execution of first user-operation
///
/// Parameters:
/// - [launchpadInitData]: Encoded initialization data for the launchpad
/// - [launchpad]: The launchpad contract address
/// - [owners]: List of owner addresses
/// - [threshold]: Required number of owner signatures
/// - [module]: The Safe 4337 module address
/// - [singleton]: The Safe singleton contract address
/// - [validators]: Optional list of validator module initializations
///
/// Returns the keccak256 hash of the encoded parameters.
Uint8List get7579InitHash({
  required Uint8List launchpadInitData,
  required Address launchpad,
  required Iterable<Address> owners,
  required int threshold,
  required Safe4337ModuleAddress module,
  required SafeSingletonAddress singleton,
  Iterable<ModuleInit>? validators,
}) {
  final encodedData = abi.encode(
    [
      "address",
      "address[]",
      "uint256",
      "address",
      "bytes",
      "address",
      "(address,bytes)[]",
    ],
    [
      singleton.address,
      owners.toList(),
      BigInt.from(threshold),
      launchpad,
      launchpadInitData,
      module.address,
      validators?.map((e) => [e.module, e.initData]).toList() ?? [],
    ],
  );
  return keccak256(encodedData);
}

/// Encodes calldata for initializing a Safe7579 setup.
///
/// Parameters:
/// - [launchpad]: The launchpad contract address
/// - [initHash]: The initialization hash
/// - [setupTo]: The target address for setup
/// - [setupData]: The setup data
///
/// Returns encoded calldata as a Uint8List.
Uint8List encode7579InitCalldata({
  required Address launchpad,
  required Uint8List initHash,
  required Address setupTo,
  required Uint8List setupData,
}) {
  return Contract.encodeFunctionCall(
    "preValidationSetup",
    launchpad,
    Safe7579Abis.get("preValidationSetup"),
    [initHash, setupTo, setupData],
  );
}

/// Encodes an execution mode for Safe7579 transactions.
///
/// Parameters:
/// - [executionMode]: The execution mode configuration
///
/// Returns the encoded execution mode as a Uint8List.
Uint8List encodeExecutionMode(ExecutionMode executionMode) {
  final typeBytes = intToBytes(BigInt.from(executionMode.type.value));
  final revertOnErrorBytes = intToBytes(
    executionMode.revertOnError ? BigInt.one : BigInt.zero,
  );
  final selectorBytes = (executionMode.selector ?? Uint8List(0)).padToNBytes(4);
  final contextBytes = (executionMode.context ?? Uint8List(0)).padToNBytes(22);

  return typeBytes
      .concat(revertOnErrorBytes)
      .concat(Uint8List(0).padToNBytes(4))
      .concat(selectorBytes)
      .concat(contextBytes);
}

/// Encodes a Safe7579 transaction call.
///
/// Parameters:
/// - [mode]: The execution mode
/// - [calldata]: List of transaction calldata
/// - [contractAddress]: The target contract address
///
/// Returns the encoded transaction call as a Uint8List.
Uint8List encode7579Call(
  ExecutionMode mode,
  List<Uint8List> calldata,
  Address contractAddress,
) {
  return Contract.encodeFunctionCall(
    'execute',
    contractAddress,
    Safe7579Abis.get('execute7579'),
    [
      encodeExecutionMode(mode),
      mode.type == CallType.batchcall
          ? encode7579BatchCall(calldata)
          : calldata.first,
    ],
  );
}

/// Encodes multiple transaction calls for batch execution.
///
/// Parameters:
/// - [calldatas]: List of transaction calldatas to batch
///
/// Returns the encoded batch call as a Uint8List.
Uint8List encode7579BatchCall(List<Uint8List> calldatas) {
  return abi.encode(
    ["(address,uint256,bytes)[]"],
    [
      calldatas
          .map(
            (calldata) => [
              Address(calldata.sublist(0, 20)), // address 20 bytes
              bytesToInt(calldata.sublist(20, 52)), // uint256 32 bytes
              calldata.sublist(52), // rest
            ],
          )
          .toList(),
    ],
  );
}

/// Encodes post-setup initialization calldata for a Safe7579.
///
/// Parameters:
/// - [initializer]: The Safe7579 initializer configuration
/// - [calldata]: List of transaction calldata
/// - [contractAddress]: The target contract address
/// - [type]: The call type
///
/// Returns the encoded post-setup initialization calldata as a Uint8List.
Uint8List _encodePostSetupInitCalldata(
  _Safe7579Initializer initializer,
  List<Uint8List> calldata,
  Address contractAddress,
  CallType type,
) {
  return Contract.encodeFunctionCall(
    "setupSafe",
    initializer.launchpad,
    Safe7579Abis.get("setup7579Safe"),
    [
      [
        initializer.singleton.address,
        initializer.owners.toList(),
        BigInt.from(initializer.threshold),
        initializer.launchpad,
        initializer.getLaunchpadInitData(),
        initializer.module.address,
        initializer.validators?.map((e) => [e.module, e.initData]).toList() ??
            [],
        encode7579Call(ExecutionMode(type: type), calldata, contractAddress),
      ],
    ],
  );
}
