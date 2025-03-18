part of '../../variance_dart.dart';

abstract class Safe7579Initializer extends _SafeInitializer {
  Safe7579Initializer(
      {required super.owners,
      required super.threshold,
      required super.module,
      required super.singleton});

  /// The address of the launchpad contract that will be used for initialization.
  EthereumAddress get launchpad;

  /// Optional list of validator module configurations to be initialized with the Safe.
  Iterable<ModuleInit>? get validators;

  /// Optional list of executor module configurations to be initialized with the Safe.
  Iterable<ModuleInit>? get executors;

  /// Optional list of fallback module configurations to be initialized with the Safe.
  Iterable<ModuleInit>? get fallbacks;

  /// Optional list of hook module configurations to be initialized with the Safe.
  Iterable<ModuleInit>? get hooks;

  /// Optional list of attester addresses that can validate transactions.
  Iterable<EthereumAddress>? get attesters;

  /// Optional threshold for the number of attesters required to validate a transaction.
  int? get attestersThreshold;

  /// Generates the initialization data for the launchpad contract.
  ///
  /// Returns a [Uint8List] containing the encoded initialization data.
  Uint8List getLaunchpadInitData();
}

class _Safe7579Initializer extends Safe7579Initializer {
  @override
  final EthereumAddress launchpad;
  @override
  final Iterable<ModuleInit>? validators;
  @override
  final Iterable<ModuleInit>? executors;
  @override
  final Iterable<ModuleInit>? fallbacks;
  @override
  final Iterable<ModuleInit>? hooks;
  @override
  final Iterable<EthereumAddress>? attesters;
  @override
  final int? attestersThreshold;

  _Safe7579Initializer({
    required super.owners,
    required super.threshold,
    required super.module,
    required super.singleton,
    required this.launchpad,
    this.validators,
    this.executors,
    this.fallbacks,
    this.hooks,
    this.attesters,
    this.attestersThreshold,
  });

  @override
  Uint8List getLaunchpadInitData() {
    return encode7579LaunchpadInitdata(
        launchpad: launchpad,
        module: module,
        attesters: attesters,
        executors: executors,
        fallbacks: fallbacks,
        hooks: hooks,
        attestersThreshold: attestersThreshold);
  }

  @override
  Uint8List getInitializer() {
    final initData = getLaunchpadInitData();
    final initHash = get7579InitHash(
        launchpadInitData: initData,
        launchpad: launchpad,
        owners: owners,
        threshold: threshold,
        module: module,
        singleton: singleton);
    return encode7579InitCalldata(launchpad: launchpad, initHash: initHash);
  }
}
