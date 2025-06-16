part of '../../variance_dart.dart';

/// A class that represents gas settings for Ethereum transactions.
class GasOverrides {
  final GasTransformFn callGas;
  final GasTransformFn verificationGas;
  final GasTransformFn preVerificationGas;
  final GasTransformFn maxFeePerGas;
  final GasTransformFn maxPriorityFeePerGas;

  GasOverrides({
    this.callGas,
    this.verificationGas,
    this.preVerificationGas,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  });
}

/// A stateless mixin that provides gas override functionality for smart wallet operations
mixin _GasOverridesActions on SmartWalletBase {
  set gasOverrides(GasOverrides overrides) => state.gasOverrides = overrides;

  /// Applies the gas settings to a user operation, by multiplying the gas limits by a certain percentage.
  ///
  /// [op] is the user operation to which the gas settings should be applied.
  ///
  /// Returns a new [UserOperation] object with the updated gas settings.
  @protected
  UserOperation overrideGas(UserOperation op) {
    if (state.gasOverrides == null) return op;

    final newCallGas = state.gasOverrides?.callGas?.call(op.callGasLimit);

    final newVerificationGas = state.gasOverrides?.verificationGas?.call(
      op.verificationGasLimit,
    );

    final newPreVerificationGas = state.gasOverrides?.preVerificationGas?.call(
      op.preVerificationGas,
    );

    final newMaxFeePerGas = state.gasOverrides?.maxFeePerGas?.call(
      op.maxFeePerGas,
    );

    final newMaxPriorityFeePerGas = state.gasOverrides?.maxPriorityFeePerGas
        ?.call(op.maxPriorityFeePerGas);

    if (newCallGas == op.callGasLimit &&
        newVerificationGas == op.verificationGasLimit &&
        newPreVerificationGas == op.preVerificationGas &&
        newMaxFeePerGas == null &&
        newMaxPriorityFeePerGas == null) {
      return op;
    }

    return op.copyWith(
      callGasLimit: newCallGas,
      verificationGasLimit: newVerificationGas,
      preVerificationGas: newPreVerificationGas,
      maxFeePerGas: newMaxFeePerGas,
      maxPriorityFeePerGas: newMaxPriorityFeePerGas,
    );
  }
}
