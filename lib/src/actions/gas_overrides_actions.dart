part of '../../variance_dart.dart';

typedef Percent = double;
typedef GasTransformFn = BigInt Function(BigInt?)?;

/// A class that represents gas settings for Ethereum transactions.
class GasSettings {
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

  GasSettings({
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
            RangeOutOfBounds("Wrong Gas multiplier percentage", 0, 100));
}

/// A mixin that provides methods for managing gas settings for user operations.
mixin _gasOverridesActions {
  /// The gas settings for user operations.
  GasSettings _gasParams = GasSettings();

  set gasOverride(GasSettings gasParams) => _gasParams = gasParams;

  /// Sets the gas settings for user operations.
  ///
  /// [gasParams] is an instance of the [GasSettings] class containing the gas settings.
  @Deprecated("use [gasOverride] method")
  set gasSettings(GasSettings gasParams) => _gasParams = gasParams;

  /// Applies the gas settings to a user operation, by multiplying the gas limits by a certain percentage.
  ///
  /// [op] is the user operation to which the gas settings should be applied.
  ///
  /// Returns a new [UserOperation] object with the updated gas settings.
  UserOperation _applyGasOverrides(UserOperation op) {
    // Handle legacy multiplier logic
    final cglMultiplier = _gasParams.callGasMultiplierPercentage / 100 + 1;
    final vglMultiplier =
        _gasParams.verificationGasMultiplierPercentage / 100 + 1;
    final preVglMultiplier =
        _gasParams.preVerificationGasMultiplierPercentage / 100 + 1;

    final newCallGas = _gasParams.callGas != null
        ? _gasParams.callGas!(op.callGasLimit)
        : BigInt.from(op.callGasLimit.toDouble() * cglMultiplier);

    final newVerificationGas = _gasParams.verificationGas != null
        ? _gasParams.verificationGas!(op.verificationGasLimit)
        : BigInt.from(op.verificationGasLimit.toDouble() * vglMultiplier);

    final newPreVerificationGas = _gasParams.preVerificationGas != null
        ? _gasParams.preVerificationGas!(op.preVerificationGas)
        : BigInt.from(op.preVerificationGas.toDouble() * preVglMultiplier);

    final newMaxFeePerGas = _gasParams.maxFeePerGas != null
        ? _gasParams.maxFeePerGas!(op.maxFeePerGas)
        : _gasParams.userDefinedMaxFeePerGas;

    final newMaxPriorityFeePerGas = _gasParams.maxPriorityFeePerGas != null
        ? _gasParams.maxPriorityFeePerGas!(op.maxPriorityFeePerGas)
        : _gasParams.userDefinedMaxPriorityFeePerGas;

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
        maxPriorityFeePerGas: newMaxPriorityFeePerGas);
  }
}
