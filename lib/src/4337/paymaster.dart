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

class Paymaster {
  final RPCBase _rpc;
  final Chain _chain;
  Map<String, String>? _context;

  set context(Map<String, String>? context) {
    _context = context;
  }

  Paymaster(this._chain, [this._context])
      : assert(isURL(_chain.paymasterUrl),
            InvalidPaymasterUrl(_chain.paymasterUrl)),
        _rpc = RPCBase(_chain.paymasterUrl!);

  Future<UserOperation> intercept(UserOperation operation) async {
    final paymasterResponse = await sponsorUserOperation(
        operation.toMap(), _chain.entrypoint, _context);

    return operation.copyWith(
      paymasterAndData: paymasterResponse.paymasterAndData,
      preVerificationGas: paymasterResponse.preVerificationGas,
      verificationGasLimit: paymasterResponse.verificationGasLimit,
      callGasLimit: paymasterResponse.callGasLimit,
    );
  }

  Future<PaymasterResponse> sponsorUserOperation(Map<String, dynamic> userOp,
      EntryPoint entrypoint, Map<String, String>? context) async {
    final response = await _rpc.send<Map<String, dynamic>>(
        'pm_sponsorUserOperation', [userOp, entrypoint.hex, context]);
    return PaymasterResponse.fromMap(response);
  }
}
