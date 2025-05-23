import 'package:web3dart/web3dart.dart';

/// Contract ABIs
/// Getters for contract ABIs for onchain operations
class Safe7579Abis {
  /// Get contract ABI
  /// - `name`: name of the contract
  ///
  /// Returns ABI of the contract.
  static ContractAbi get(String name) {
    String abi;
    switch (name) {
      case 'setup7579Safe':
        abi =
            '[{"type":"function","name":"setupSafe","inputs":[{"name":"initData","type":"tuple","internalType":"struct Safe7579Launchpad.InitData","components":[{"name":"singleton","type":"address","internalType":"address"},{"name":"owners","type":"address[]","internalType":"address[]"},{"name":"threshold","type":"uint256","internalType":"uint256"},{"name":"setupTo","type":"address","internalType":"address"},{"name":"setupData","type":"bytes","internalType":"bytes"},{"name":"safe7579","type":"address","internalType":"contract ISafe7579"},{"name":"validators","type":"tuple[]","internalType":"struct ModuleInit[]","components":[{"name":"module","type":"address","internalType":"address"},{"name":"initData","type":"bytes","internalType":"bytes"}]},{"name":"callData","type":"bytes","internalType":"bytes"}]}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'initSafe7579':
        abi =
            '[{"type":"function","name":"initSafe7579","inputs":[{"name":"safe7579","type":"address","internalType":"address"},{"name":"executors","type":"tuple[]","internalType":"struct ModuleInit[]","components":[{"name":"module","type":"address","internalType":"address"},{"name":"initData","type":"bytes","internalType":"bytes"}]},{"name":"fallbacks","type":"tuple[]","internalType":"struct ModuleInit[]","components":[{"name":"module","type":"address","internalType":"address"},{"name":"initData","type":"bytes","internalType":"bytes"}]},{"name":"hooks","type":"tuple[]","internalType":"struct ModuleInit[]","components":[{"name":"module","type":"address","internalType":"address"},{"name":"initData","type":"bytes","internalType":"bytes"}]},{"name":"attesters","type":"address[]","internalType":"address[]"},{"name":"threshold","type":"uint8","internalType":"uint8"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'preValidationSetup':
        abi =
            '[{"type":"function","name":"preValidationSetup","inputs":[{"name":"initHash","type":"bytes32","internalType":"bytes32"},{"name":"to","type":"address","internalType":"address"},{"name":"preInit","type":"bytes","internalType":"bytes"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'execute7579':
        abi =
            '[{"type":"function","name":"execute","inputs":[{"name":"mode","type":"bytes32","internalType":"ExecMode"},{"name":"executionCalldata","type":"bytes","internalType":"bytes"}],"outputs":[],"stateMutability":"payable"}]';
        break;
      case 'accountId':
        abi =
            '[{"type":"function","name":"accountId","inputs":[],"outputs":[{"name":"accountImplementationId","type":"string","internalType":"string"}],"stateMutability":"pure"}]';
        break;
      case 'isModuleInstalled':
        abi =
            '[{"type":"function","name":"isModuleInstalled","inputs":[{"name":"moduleType","type":"uint256","internalType":"uint256"},{"name":"module","type":"address","internalType":"address"},{"name":"additionalContext","type":"bytes","internalType":"bytes"}],"outputs":[{"name":"","type":"bool","internalType":"bool"}],"stateMutability":"view"}]';
        break;
      case 'supportsModule':
        abi =
            '[{"type":"function","name":"supportsModule","inputs":[{"name":"moduleTypeId","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"","type":"bool","internalType":"bool"}],"stateMutability":"pure"}]';
        break;
      case 'supportsExecutionMode':
        abi =
            '[{"type":"function","name":"supportsExecutionMode","inputs":[{"name":"encodedMode","type":"bytes32","internalType":"ModeCode"}],"outputs":[{"name":"supported","type":"bool","internalType":"bool"}],"stateMutability":"pure"}]';
        break;
      case 'installModule':
        abi =
            '[{"type":"function","name":"installModule","inputs":[{"name":"moduleType","type":"uint256","internalType":"uint256"},{"name":"module","type":"address","internalType":"address"},{"name":"initData","type":"bytes","internalType":"bytes"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'uninstallModule':
        abi =
            '[{"type":"function","name":"uninstallModule","inputs":[{"name":"moduleType","type":"uint256","internalType":"uint256"},{"name":"module","type":"address","internalType":"address"},{"name":"deInitData","type":"bytes","internalType":"bytes"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'iModule':
        abi =
            '[{"type":"function","name":"isInitialized","inputs":[{"name":"smartAccount","type":"address","internalType":"address"}],"outputs":[{"name":"","type":"bool","internalType":"bool"}],"stateMutability":"view"},{"type":"function","name":"isModuleType","inputs":[{"name":"moduleTypeId","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"","type":"bool","internalType":"bool"}],"stateMutability":"view"},{"type":"function","name":"execute","inputs":[{"name":"data","type":"bytes","internalType":"bytes"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      default:
        throw 'ABI of $name is not available by default. Please provide the ABI manually.';
    }
    return ContractAbi.fromJson(abi, name);
  }
}
