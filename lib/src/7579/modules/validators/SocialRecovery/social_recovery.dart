part of '../../module.dart';

class SocialRecovery extends ValidatorModuleInterface {
  SocialRecovery(super.wallet);

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "SocialRecoveryValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  Future<UserOperationReceipt?> addGuardian(EthereumAddress guardian) async {
    final calldata =
        _deployedModule.contract.function('addGuardian').encodeCall([guardian]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<List<EthereumAddress>?> getGuardians(
      [EthereumAddress? account]) async {
    final result = await wallet.readContract(
        address, social_recovery_abi, 'getGuardians',
        params: [account ?? wallet.address]);
    return result.firstOrNull;
  }

  Future<BigInt?> guardianCount([EthereumAddress? account]) async {
    final result = await wallet.readContract(
        address, social_recovery_abi, 'guardianCount',
        params: [account ?? wallet.address]);
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> removeGuardian(EthereumAddress guardian) async {
    final guardians = await getGuardians() ?? [];
    final currentGuardianIndex = guardians.indexOf(guardian);

    EthereumAddress prevGuardian;
    if (currentGuardianIndex == -1) {
      throw Exception('Guardian not found');
    } else if (currentGuardianIndex == 0) {
      prevGuardian = SENTINEL_ADDRESS;
    } else {
      prevGuardian = guardians[currentGuardianIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeGuardian')
        .encodeCall([prevGuardian, guardian]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> setThreshold(int threshold) async {
    final calldata = _deployedModule.contract
        .function('setThreshold')
        .encodeCall([BigInt.from(threshold)]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<BigInt?> threshold([EthereumAddress? account]) async {
    final result = await wallet.readContract(
        address, social_recovery_abi, 'threshold',
        params: [account ?? wallet.address]);
    return result.firstOrNull;
  }

  final _deployedModule = SocialRecoveryContract(getAddress());

  static BigInt _initThreshold = BigInt.zero;

  static List<EthereumAddress> _initGuardians = [];

  // must be static
  static void setInitVars(int threshold, List<EthereumAddress> guardians) {
    guardians.sort((a, b) => a.hex.compareTo(b.hex));
    _initThreshold = BigInt.from(threshold);
    _initGuardians = guardians;
  }

  // must be static
  static Uint8List getInitData() {
    return abi
        .encode(["uint256", "address[]"], [_initThreshold, _initGuardians]);
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
        '0xA04D053b3C8021e8D5bF641816c42dAA75D8b597');
  }
}
