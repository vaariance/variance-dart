part of '../../variance_dart.dart';

/// A mixin that implements the `BundlerProviderBase` interface and provides methods
/// for interacting with a bundler service. The bundler is responsible for sending
/// and tracking user operations (UserOps) on EVM-compatible blockchains that
mixin _bundlerActions implements BundlerProviderBase {
  /// The remote procedure call (RPC) client used to communicate with the bundler.
  late final RPCBase _bundlerRpc;

  @override
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EntryPointAddress entrypoint) async {
    final opGas = await _bundlerRpc
        .send<Map<String, dynamic>>('eth_estimateUserOperationGas', [
      userOp,
      entrypoint.address.hex,
      // ? not sure if this should be global or only applied to pimlico only
      {
        '${userOp['sender']}': {"balance": "0x56BC75E2D63100000"}
      }
    ]);
    return UserOperationGas.fromMap(opGas);
  }

  @override
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    final opExtended = await _bundlerRpc
        .send<Map<String, dynamic>>('eth_getUserOperationByHash', [userOpHash]);
    return UserOperationByHash.fromMap(opExtended);
  }

  @override
  Future<UserOperationReceipt?> getUserOpReceipt(String userOpHash) async {
    final opReceipt = await _bundlerRpc.send<Map<String, dynamic>>(
        'eth_getUserOperationReceipt', [userOpHash]);
    return UserOperationReceipt.fromMap(opReceipt);
  }

  @override
  Future<UserOperationResponse> sendRawUserOperation(
      Map<String, dynamic> userOp, EntryPointAddress entrypoint) async {
    final opHash = await _bundlerRpc.send<String>(
        'eth_sendUserOperation', [userOp, entrypoint.address.hex]);
    return UserOperationResponse(opHash, getUserOpReceipt);
  }

  @override
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList =
        await _bundlerRpc.send<List<dynamic>>('eth_supportedEntryPoints');
    return List.castFrom(entrypointList);
  }

  /// Initializes the bundler actions by setting up the RPC client.
  ///
  /// [chain] is an object representing the blockchain chain configuration.
  /// The chain object must contain a valid bundler URL.
  ///
  /// This method validates the bundler URL and initializes the RPC client
  /// that will be used for all bundler-related operations.
  /// Throws [InvalidBundlerUrl] if the bundler URL is not valid.
  void _setupBundlerActions(Chain chain) {
    assert(chain.bundlerUrl.isURL(), InvalidBundlerUrl(chain.bundlerUrl));
    _bundlerRpc = RPCBase(chain.bundlerUrl!);
  }
}
