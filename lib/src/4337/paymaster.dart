part of '../../variance.dart';

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

  factory PaymasterResponse.fromMap(Map<String, dynamic> map) {
    return PaymasterResponse(
      paymasterAndData: hexToBytes(map['paymasterAndData']),
      preVerificationGas: BigInt.parse(map['preVerificationGas']),
      verificationGasLimit: BigInt.parse(map['verificationGasLimit']),
      callGasLimit: BigInt.parse(map['callGasLimit']),
    );
  }
}

/// Represents a Paymaster contract for sponsoring user operations.
class Paymaster implements PaymasterBase {
  final RPCBase _rpc;
  final Chain _chain;

  /// The context data for the Paymaster.
  ///
  /// This is an optional parameter and can be used to provide additional context
  /// information to the Paymaster when sponsoring user operations.
  Map<String, String>? _context;

  @override
  set context(Map<String, String>? context) {
    _context = context;
  }

  /// Creates a new instance of the [Paymaster] class.
  ///
  /// [_chain] is the Ethereum chain configuration.
  /// [_context] is an optional map containing the context data for the Paymaster.
  ///
  /// Throws an [InvalidPaymasterUrl] exception if the paymaster URL in the
  /// provided chain configuration is not a valid URL.
  Paymaster(this._chain, [this._context])
      : assert(isURL(_chain.paymasterUrl),
            InvalidPaymasterUrl(_chain.paymasterUrl)),
        _rpc = RPCBase(_chain.paymasterUrl!);

  @override
  Future<UserOperation> intercept(UserOperation operation) async {
    final paymasterResponse = await sponsorUserOperation(
        operation.toMap(), _chain.entrypoint, _context);

    // Create a new UserOperation with the updated Paymaster data and gas limits
    return operation.copyWith(
      paymasterAndData: paymasterResponse.paymasterAndData,
      preVerificationGas: paymasterResponse.preVerificationGas,
      verificationGasLimit: paymasterResponse.verificationGasLimit,
      callGasLimit: paymasterResponse.callGasLimit,
    );
  }

  @override
  Future<PaymasterResponse> sponsorUserOperation(Map<String, dynamic> userOp,
      EntryPointAddress entrypoint, Map<String, String>? context) async {
    final response = await _rpc.send<Map<String, dynamic>>(
        'pm_sponsorUserOperation', [userOp, entrypoint.address.hex, context]);

    // Parse the response into a PaymasterResponse object
    return PaymasterResponse.fromMap(response);
  }
}
