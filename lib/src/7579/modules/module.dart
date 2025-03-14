import 'dart:typed_data';

import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/crypto.dart';

import '../StandardModuleInterface/interface.dart';
import 'executors/OwnableExecutor/ownable_executor.m.dart';
import 'hooks/RegistryHook/registry_hook.m.dart';
import 'validators/OwnableValidator/ownable_validator.m.dart';
import 'validators/SocialRecovery/social_recovery.m.dart';

// ------------ EXECUTORS -------------- //
part 'executors/OwnableExecutor/ownable_executor.dart';
// ------------ HOOKS -------------- //
part 'hooks/RegistryHook/registry_hook.dart';
// ------------ VALIDATORS -------------- //
part 'validators/OwnableValidator/ownable_validator.dart';
part 'validators/SocialRecovery/social_recovery.dart';
