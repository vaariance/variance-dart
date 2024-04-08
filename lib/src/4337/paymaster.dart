part of '../../variance_dart.dart';

/// Represents a Paymaster contract for sponsoring user operations.
class Paymaster implements PaymasterBase {
  final RPCBase _rpc;
  final Chain _chain;

  /// The address of the Paymaster contract.
  ///
  /// This is an optional parameter and can be left null if the paymaster address
  /// is not known or needed.
  EthereumAddress? _paymasterAddress;

  /// The context data for the Paymaster.
  ///
  /// This is an optional parameter and can be used to provide additional context
  /// information to the Paymaster when sponsoring user operations.
  Map<String, String>? _context;

  /// Creates a new instance of the [Paymaster] class.
  ///
  /// [_chain] is the Ethereum chain configuration.
  /// [_paymasterAddress] is an optional address of the Paymaster contract.
  /// [_context] is an optional map containing the context data for the Paymaster.
  ///
  /// Throws an [InvalidPaymasterUrl] exception if the paymaster URL in the
  /// provided chain configuration is not a valid URL.
  Paymaster(this._chain, [this._paymasterAddress, this._context])
      : assert(_chain.paymasterUrl.isURL(),
            InvalidPaymasterUrl(_chain.paymasterUrl)),
        _rpc = RPCBase(_chain.paymasterUrl!);

  @override
  set context(Map<String, String>? context) {
    _context = context;
  }

  @override
  set paymasterAddress(EthereumAddress? address) {
    _paymasterAddress = address;
  }

  @override
  Future<UserOperation> intercept(UserOperation op) async {
    if (_paymasterAddress != null) {
      op.paymasterAndData = Uint8List.fromList([
        ..._paymasterAddress!.addressBytes,
        ...op.paymasterAndData.sublist(20)
      ]);
    }
    final paymasterResponse = await sponsorUserOperation(
        op.toMap(_chain.entrypoint.version), _chain.entrypoint, _context);

    // Create a new UserOperation with the updated Paymaster data and gas limits
    return op.copyWith(
      paymasterAndData: paymasterResponse.paymasterAndData,
      preVerificationGas: paymasterResponse.preVerificationGas,
      verificationGasLimit: paymasterResponse.verificationGasLimit,
      callGasLimit: paymasterResponse.callGasLimit,
    );
  }

  @override
  Future<PaymasterResponse> sponsorUserOperation(Map<String, dynamic> userOp,
      EntryPointAddress entrypoint, Map<String, String>? context) async {
    final request = [userOp, entrypoint.address.hex];
    if (context != null) {
      request.add(context);
    }
    final response = await _rpc.send<Map<String, dynamic>>(
        'pm_sponsorUserOperation', request);

    // Parse the response into a PaymasterResponse object
    return PaymasterResponse.fromMap(response);
  }
}

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
    final List<BigInt> accountGasLimits = map['accountGasLimits'] != null
        ? unpackUints(map['accountGasLimits'])
        : [
            BigInt.parse(map['verificationGasLimit']),
            BigInt.parse(map['callGasLimit'])
          ];

    final paymasterAndData = map['paymasterAndData'] != null
        ? hexToBytes(map['paymasterAndData'])
        : Uint8List.fromList([
            ...EthereumAddress.fromHex(map['paymaster']).addressBytes,
            ...packUints(BigInt.parse(map['paymasterVerificationGasLimit']),
                BigInt.parse(map['paymasterPostOpGasLimit'])),
            ...hexToBytes(map["paymasterData"])
          ]);

    return PaymasterResponse(
        paymasterAndData: paymasterAndData,
        preVerificationGas: BigInt.parse(map['preVerificationGas']),
        verificationGasLimit: accountGasLimits[0],
        callGasLimit: accountGasLimits[1]);
  }
}
