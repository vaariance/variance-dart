enum AppEnums { modularAccounts, nonModularAccounts }

enum ModuleType {
  socialRecovery,
  ownableValidator,
  ownableExecutor,
  registryHook,
  none
}

enum ExecutionMode { single, batch }

enum SignerTypes { passkey, eoa, privateKey, none }

enum AccountType { light, safe, modular, none }
