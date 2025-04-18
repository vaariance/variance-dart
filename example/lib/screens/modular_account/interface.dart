import 'dart:typed_data';

import 'package:web3_signers/web3_signers.dart';

import '../../constants/enums.dart';
import '../../models/user_operations.dart';
import '../widgets/modular_action_card.dart';

/// Interface for modular account operations
abstract class ModularAccountInterface {
  /// Install a single module
  Future<UserOperationResponse> installModule(
      ModuleType type,
      EthereumAddress moduleAddress,
      Uint8List initData,
      );

  /// Install multiple modules
  Future<UserOperationResponse> installModules(
      List<ModuleType> types,
      List<EthereumAddress> moduleAddresses,
      List<Uint8List> initDatas,
      );

  /// Uninstall a single module
  Future<UserOperationResponse> uninstallModule(
      ModuleType type,
      EthereumAddress moduleAddress,
      Uint8List initData,
      );

  /// Uninstall multiple modules
  Future<UserOperationResponse> uninstallModules(
      List<ModuleType> types,
      List<EthereumAddress> moduleAddresses,
      List<Uint8List> initDatas,
      );

  /// Check if a module is supported
  Future<bool> supportsModule(ModuleType type);

  /// Check if a module is installed
  Future<bool> isModuleInstalled(
      ModuleType type,
      EthereumAddress moduleAddress,
      Uint8List? context,
      );

  /// Get the account ID
  Future<String?> accountId();
}