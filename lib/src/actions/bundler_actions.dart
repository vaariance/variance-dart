part of '../../variance_dart.dart';

/// A stateless mixin that implements the `BundlerProviderBase` interface and provides methods
/// for interacting with a bundler service. The bundler is responsible for sending
/// and tracking user operations (UserOps) on EVM-compatible blockchains that
mixin _BundlerActions on SmartWalletBase implements BundlerProviderBase {
  @override
  Future<UserOperationGas> estimateUserOperationGas(
    Dict userOp,
    EntryPointAddress entrypoint,
  ) async {
    final opGas = await state.bundler.send<Dict>(
      'eth_estimateUserOperationGas',
      [
        userOp,
        entrypoint.address.hex,
        // ? not sure if this should be global or only applied to pimlico only
        {
          '${userOp['sender']}': {"balance": "0x56BC75E2D63100000"},
        },
      ],
    );
    return UserOperationGas.fromMap(opGas);
  }

  @override
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash) async {
    final opExtended = await state.bundler.send<Dict>(
      'eth_getUserOperationByHash',
      [userOpHash],
    );
    return UserOperationByHash.fromMap(opExtended);
  }

  @override
  Future<UserOperationReceipt?> getUserOpReceipt(String userOpHash) async {
    final opReceipt = await state.bundler.send<Dict>(
      'eth_getUserOperationReceipt',
      [userOpHash],
    );
    return UserOperationReceipt.fromMap(opReceipt);
  }

  @override
  Future<UserOperationResponse> sendRawUserOperation(
    Dict userOp,
    EntryPointAddress entrypoint,
  ) async {
    final opHash = await state.bundler.send<String>('eth_sendUserOperation', [
      userOp,
      entrypoint.address.hex,
    ]);
    return UserOperationResponse(opHash, getUserOpReceipt);
  }

  @override
  Future<List<String>> supportedEntryPoints() async {
    final entrypointList = await state.bundler.send<List<dynamic>>(
      'eth_supportedEntryPoints',
    );
    return List.castFrom(entrypointList);
  }
}
