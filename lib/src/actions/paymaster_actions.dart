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

/// Represents a Paymaster contract for sponsoring user operations.
mixin _paymasterActions implements PaymasterBase {
  late final RPCBase _paymasterRpc;

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

  late final bool _paymasterActionsEnabled;

  Chain get chain;

  @override
  set paymasterAddress(EthereumAddress? address) {
    _paymasterAddress = address;
  }

  @override
  set paymasterContext(Map<String, String>? context) {
    _context = context;
  }

  @override
  Future<UserOperation> sponsorUserOperation(UserOperation op) async {
    if (!_paymasterActionsEnabled) {
      return op;
    }
    if (_paymasterAddress != null) {
      op.paymasterAndData = Uint8List.fromList([
        ..._paymasterAddress!.addressBytes,
        ...op.paymasterAndData.sublist(20)
      ]);
    }
    final paymasterResponse = await _sponsorRawUserOperation(
        op.toMap(chain.entrypoint.version), chain.entrypoint, _context);

    // Create a new UserOperation with the updated Paymaster data and gas limits
    return op.copyWith(
      paymasterAndData: paymasterResponse.paymasterAndData,
      preVerificationGas: paymasterResponse.preVerificationGas,
      verificationGasLimit: paymasterResponse.verificationGasLimit,
      callGasLimit: paymasterResponse.callGasLimit,
    );
  }

  /// Sets up the paymaster actions with the given chain configuration and optional parameters.
  ///
  /// [paymasterAddress] is an optional address of the Paymaster contract.
  /// [context] is an optional map containing context data for the Paymaster.
  ///
  /// The paymaster will be enabled if the chain configuration contains a valid paymaster URL.
  /// If the URL is invalid, the paymaster will be disabled.
  _setupPaymasterActions(
      [EthereumAddress? paymasterAddress, Map<String, String>? context]) {
    if (chain.paymasterUrl.isURL()) {
      _paymasterRpc = RPCBase(chain.paymasterUrl!);
      _paymasterAddress = paymasterAddress;
      _context = context;
      _paymasterActionsEnabled = true;
    } else {
      _paymasterActionsEnabled = false;
    }
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
      Map<String, dynamic> userOp,
      EntryPointAddress entrypoint,
      Map<String, String>? context) async {
    final request = [userOp, entrypoint.address.hex];
    if (context != null) {
      request.add(context);
    }
    final response = await _paymasterRpc.send<Map<String, dynamic>>(
        'pm_sponsorUserOperation', request);

    // Parse the response into a PaymasterResponse object
    return PaymasterResponse.fromMap(response);
  }
}
