part of '../../module.dart';

class RegistryHook extends HookModuleInterface {
  RegistryHook(super.wallet);

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "RegistryHook";

  @override
  ModuleType get type => ModuleType.hook;

  @override
  String get version => '1.0.0';

  Future<EthereumAddress?> registry([EthereumAddress? account]) async {
    final result = await wallet.readContract(
        address, registry_hook_abi, 'registry',
        params: [account ?? wallet.address]);
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> setRegistry(EthereumAddress registry) async {
    final calldata =
        _deployedModule.contract.function('setRegistry').encodeCall([registry]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  final _deployedModule = RegistryHookContract(getAddress());

  static EthereumAddress _initRegistry =
      EthereumAddress.fromHex('0x000000000069E2a187AEFFb852bF3cCdC95151B2');

  // must be static
  static void setInitVars(EthereumAddress registry) {
    _initRegistry = registry;
  }

  // must be static
  static Uint8List getInitData() {
    return _initRegistry.addressBytes;
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
        '0x0ac6160DBA30d665cCA6e6b6a2CDf147DC3dED22');
  }
}
