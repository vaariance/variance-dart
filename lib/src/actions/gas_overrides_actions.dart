part of '../../variance_dart.dart';

@Deprecated("Use GasOverrides instead")
class GasSettings extends GasOverrides {
  GasSettings({
    super.callGasMultiplierPercentage,
    super.verificationGasMultiplierPercentage,
    super.preVerificationGasMultiplierPercentage,
    super.userDefinedMaxFeePerGas,
    super.userDefinedMaxPriorityFeePerGas,
  });
}

/// A class that represents gas settings for Ethereum transactions.
class GasOverrides {
  // New approach with direct gas value modifications
  final GasTransformFn callGas;
  final GasTransformFn verificationGas;
  final GasTransformFn preVerificationGas;
  final GasTransformFn maxFeePerGas;
  final GasTransformFn maxPriorityFeePerGas;

  // Legacy fields
  @Deprecated("Use callGas instead")
  Percent callGasMultiplierPercentage;
  @Deprecated("Use verificationGas instead")
  Percent verificationGasMultiplierPercentage;
  @Deprecated("Use preVerificationGas instead")
  Percent preVerificationGasMultiplierPercentage;
  @Deprecated("Use maxFeePerGas instead")
  BigInt? userDefinedMaxFeePerGas;
  @Deprecated("Use maxPriorityFeePerGas instead")
  BigInt? userDefinedMaxPriorityFeePerGas;

  GasOverrides({
    this.callGas,
    this.verificationGas,
    this.preVerificationGas,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    // Legacy parameters
    @Deprecated("Use callGas transform fn instead")
    this.callGasMultiplierPercentage = 0,
    @Deprecated("Use verificationGas transform fn instead")
    this.verificationGasMultiplierPercentage = 0,
    @Deprecated("Use preVerificationGas transform fn instead")
    this.preVerificationGasMultiplierPercentage = 0,
    @Deprecated("Use maxFeePerGas transform fn instead")
    this.userDefinedMaxFeePerGas,
    @Deprecated("Use maxPriorityFeePerGas transform fn instead")
    this.userDefinedMaxPriorityFeePerGas,
  }) : assert(
         callGasMultiplierPercentage >= 0 &&
             callGasMultiplierPercentage <= 100 &&
             verificationGasMultiplierPercentage >= 0 &&
             preVerificationGasMultiplierPercentage >= 0,
         RangeOutOfBounds("Wrong Gas multiplier percentage", 0, 100),
       );
}

/// A stateless mixin that provides gas override functionality for smart wallet operations
mixin _GasOverridesActions on SmartWalletBase {
  set gasOverrides(GasOverrides overrides) => state.gasOverrides = overrides;

  /// Sets the gas settings for user operations.
  ///
  /// [gasParams] is an instance of the [GasSettings] class containing the gas settings.
  @Deprecated("use [gasOverrides] setter")
  set gasSettings(GasSettings gasParams) => state.gasOverrides = gasParams;

  /// Applies the gas settings to a user operation, by multiplying the gas limits by a certain percentage.
  ///
  /// [op] is the user operation to which the gas settings should be applied.
  ///
  /// Returns a new [UserOperation] object with the updated gas settings.
  @protected
  UserOperation overrideGas(UserOperation op) {
    if (state.gasOverrides == null) return op;

    // Handle legacy multiplier logic
    // ! To bo removed ---- start
    final cglMultiplier =
        state.gasOverrides!.callGasMultiplierPercentage / 100 + 1;
    final vglMultiplier =
        state.gasOverrides!.verificationGasMultiplierPercentage / 100 + 1;
    final preVglMultiplier =
        state.gasOverrides!.preVerificationGasMultiplierPercentage / 100 + 1;
    // ! To bo removed ---- end

    final newCallGas =
        state.gasOverrides?.callGas != null
            ? state.gasOverrides?.callGas!(op.callGasLimit)
            : BigInt.from(op.callGasLimit.toDouble() * cglMultiplier);

    final newVerificationGas =
        state.gasOverrides?.verificationGas != null
            ? state.gasOverrides?.verificationGas!(op.verificationGasLimit)
            : BigInt.from(op.verificationGasLimit.toDouble() * vglMultiplier);

    final newPreVerificationGas =
        state.gasOverrides?.preVerificationGas != null
            ? state.gasOverrides?.preVerificationGas!(op.preVerificationGas)
            : BigInt.from(op.preVerificationGas.toDouble() * preVglMultiplier);

    final newMaxFeePerGas =
        state.gasOverrides?.maxFeePerGas != null
            ? state.gasOverrides?.maxFeePerGas!(op.maxFeePerGas)
            : state.gasOverrides?.userDefinedMaxFeePerGas;

    final newMaxPriorityFeePerGas =
        state.gasOverrides?.maxPriorityFeePerGas != null
            ? state.gasOverrides?.maxPriorityFeePerGas!(op.maxPriorityFeePerGas)
            : state.gasOverrides?.userDefinedMaxPriorityFeePerGas;

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
