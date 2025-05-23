part of '../../variance_dart.dart';

class PaymasterResponse {
  final Uint8List paymasterAndData;
  final BigInt preVerificationGas;
  final BigInt verificationGasLimit;
  final BigInt callGasLimit;

  PaymasterResponse({
    required this.paymasterAndData,
    required this.preVerificationGas,
    required this.verificationGasLimit,
    required this.callGasLimit,
  });

  factory PaymasterResponse.fromMap(Dict map) {
    final List<BigInt> accountGasLimits =
        map['accountGasLimits'] != null
            ? unpackUints(map['accountGasLimits'])
            : [
              BigInt.parse(map['verificationGasLimit']),
              BigInt.parse(map['callGasLimit']),
            ];

    final paymasterAndData =
        map['paymasterAndData'] != null
            ? hexToBytes(map['paymasterAndData'])
            : Uint8List.fromList([
              ...EthereumAddress.fromHex(map['paymaster']).addressBytes,
              ...packUints(
                BigInt.parse(map['paymasterVerificationGasLimit']),
                BigInt.parse(map['paymasterPostOpGasLimit']),
              ),
              ...hexToBytes(map["paymasterData"]),
            ]);

    return PaymasterResponse(
      paymasterAndData: paymasterAndData,
      preVerificationGas: BigInt.parse(map['preVerificationGas']),
      verificationGasLimit: accountGasLimits[0],
      callGasLimit: accountGasLimits[1],
    );
  }
}

/// A stateless mixin that provides paymaster-related functionality for smart wallets.
///
/// This mixin implements the [PaymasterBase] interface and provides methods
/// for interacting with paymasters to sponsor user operations.
mixin _PaymasterActions on SmartWalletBase implements PaymasterBase {
  @override
  set paymasterAddress(EthereumAddress? address) =>
      state.paymasterAddress = address;

  @override
  set paymasterContext(Map<String, String>? context) =>
      state.paymasterContext = context;

  @override
  Future<UserOperation> sponsorUserOperation(UserOperation op) async {
    if (state.paymaster == null) {
      return op;
    }
    if (state.paymasterAddress != null) {
      op.paymasterAndData = Uint8List.fromList([
        ...state.paymasterAddress!.addressBytes,
        ...op.paymasterAndData.sublist(20),
      ]);
    }
    final paymasterResponse = await _sponsorRawUserOperation(
      op.toMap(chain.entrypoint.version),
      chain.entrypoint,
      state.paymasterContext,
    );

    // Create a new UserOperation with the updated Paymaster data and gas limits
    return op.copyWith(
      paymasterAndData: paymasterResponse.paymasterAndData,
      preVerificationGas: paymasterResponse.preVerificationGas,
      verificationGasLimit: paymasterResponse.verificationGasLimit,
      callGasLimit: paymasterResponse.callGasLimit,
    );
  }

  /// Sponsors a user operation with the Paymaster.
  ///
  /// [userOp] is a map containing the user operation data.
  /// [entrypoint] is the address of the EntryPoint contract.
  /// [context] is an optional map containing the context data for the Paymaster.
  ///
  /// Returns a [Future] that resolves to a [PaymasterResponse] containing the
  /// Paymaster data and gas limits for the sponsored user operation.
  ///
  /// This method calls the `pm_sponsorUserOperation` RPC method on the Paymaster
  /// contract to sponsor the user operation.
  Future<PaymasterResponse> _sponsorRawUserOperation(
    Dict userOp,
    EntryPointAddress entrypoint,
    Map<String, String>? context,
  ) async {
    final request = [userOp, entrypoint.address.hex];
    if (context != null) {
      request.add(context);
    }
    final response = await state.paymaster!.send<Dict>(
      'pm_sponsorUserOperation',
      request,
    );

    // Parse the response into a PaymasterResponse object
    return PaymasterResponse.fromMap(response);
  }
}
