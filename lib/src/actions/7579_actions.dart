part of '../../variance_dart.dart';

abstract interface class _Safe7579Interface {
  Future<UserOperationResponse> installModule(
    ModuleType type,
    Address moduleAddress,
    Uint8List initData,
  );
  Future<UserOperationResponse> installModules(
    List<ModuleType> types,
    List<Address> moduleAddresses,
    List<Uint8List> initDatas,
  );
  Future<UserOperationResponse> uninstallModule(
    ModuleType type,
    Address moduleAddress,
    Uint8List initData,
  );
  Future<UserOperationResponse> uninstallModules(
    List<ModuleType> types,
    List<Address> moduleAddresses,
    List<Uint8List> initDatas,
  );
  Future<bool?> supportsModule(ModuleType type);
  Future<bool?> isModuleInstalled(
    ModuleType type,
    Address moduleAddress, [
    Uint8List? context,
  ]);
  Future<bool?> supportsExecutionMode(ExecutionMode mode);
  Future<String?> accountId();
}

mixin _Safe7579Actions on SmartWalletBase, JsonRPCProviderBase
    implements _Safe7579Interface {
  @override
  noSuchMethod(Invocation invocation) {
    if (state.safe?.isSafe7579 ?? false) {
      final posArgs = invocation.positionalArguments;
      switch (invocation.memberName) {
        case #installModule:
          return _installModule(posArgs[0], posArgs[1], posArgs[2]);
        case #installModules:
          return _installModules(posArgs[0], posArgs[1], posArgs[2]);
        case #uninstallModule:
          return _uninstallModule(posArgs[0], posArgs[1], posArgs[2]);
        case #uninstallModules:
          return _uninstallModules(posArgs[0], posArgs[1], posArgs[2]);
        case #supportsModule:
          return _supportsModule(posArgs[0]);
        case #isModuleInstalled:
          return _isModuleInstalled(posArgs[0], posArgs[1], posArgs[2]);
        case #supportsExecutionMode:
          return _supportsExecutionMode(posArgs[0]);
        case #accountId:
          return _accountId();
        default:
          break;
      }
    }
    throw NoSuchMethodError.withInvocation(this, invocation);
  }

  Future<UserOperationResponse> _uninstallModules(
    List<ModuleType> types,
    List<Address> moduleAddresses,
    List<Uint8List> initDatas,
  ) {
    final encodedCalldatas =
        types
            .asMap()
            .entries
            .map(
              (entry) => Contract.encodeFunctionCall(
                "uninstallModule",
                address,
                Safe7579Abis.get("uninstallModule"),
                [
                  BigInt.from(entry.value.value),
                  moduleAddresses[entry.key],
                  initDatas[entry.key],
                ],
              ),
            )
            .toList();
    return sendBatchedTransaction(
      List.filled(encodedCalldatas.length, address),
      encodedCalldatas,
    );
  }

  Future<UserOperationResponse> _uninstallModule(
    ModuleType type,
    Address moduleAddress,
    Uint8List deInitData,
  ) async {
    final encodedCalldata = Contract.encodeFunctionCall(
      "uninstallModule",
      address,
      Safe7579Abis.get("uninstallModule"),
      [BigInt.from(type.value), moduleAddress, deInitData],
    );
    return sendTransaction(address, encodedCalldata);
  }

  Future<UserOperationResponse> _installModules(
    List<ModuleType> types,
    List<Address> moduleAddresses,
    List<Uint8List> initDatas,
  ) {
    final encodedCalldatas =
        types
            .asMap()
            .entries
            .map(
              (entry) => Contract.encodeFunctionCall(
                "installModule",
                address,
                Safe7579Abis.get("installModule"),
                [
                  BigInt.from(entry.value.value),
                  moduleAddresses[entry.key],
                  initDatas[entry.key],
                ],
              ),
            )
            .toList();
    return sendBatchedTransaction(
      List.filled(encodedCalldatas.length, address),
      encodedCalldatas,
    );
  }

  Future<UserOperationResponse> _installModule(
    ModuleType type,
    Address moduleAddress,
    Uint8List initData,
  ) {
    final encodedCalldata = Contract.encodeFunctionCall(
      "installModule",
      address,
      Safe7579Abis.get("installModule"),
      [BigInt.from(type.value), moduleAddress, initData],
    );
    return sendTransaction(address, encodedCalldata);
  }

  Future<bool?> _supportsExecutionMode(ExecutionMode mode) async {
    final encodedMode = encodeExecutionMode(mode);
    final result = await readContract(
      address,
      Safe7579Abis.get('supportsExecutionMode'),
      'supportsExecutionMode',
      sender: address,
      params: [encodedMode],
    );
    return result.firstOrNull;
  }

  Future<bool?> _supportsModule(ModuleType type) async {
    final result = await readContract(
      address,
      Safe7579Abis.get('supportsModule'),
      'supportsModule',
      sender: address,
      params: [BigInt.from(type.value)],
    );
    return result.firstOrNull;
  }

  Future<bool?> _isModuleInstalled(
    ModuleType type,
    Address moduleAddress, [
    Uint8List? context,
  ]) async {
    final result = await readContract(
      address,
      Safe7579Abis.get('isModuleInstalled'),
      'isModuleInstalled',
      sender: address,
      params: [BigInt.from(type.value), moduleAddress, context ?? Uint8List(0)],
    );
    return result.firstOrNull;
  }

  Future<String?> _accountId() async {
    final result = await readContract(
      address,
      Safe7579Abis.get('accountId'),
      'accountId',
      sender: address,
    );
    return result.firstOrNull;
  }

  Future<Uint8List> get7579ExecuteCalldata({
    required Address to,
    BigInt? amountInWei,
    Uint8List? innerCallData,
  }) async {
    final calldata = to.value
        .concat(intToBytes(amountInWei ?? BigInt.zero).padLeftTo32Bytes())
        .concat(innerCallData ?? Uint8List(0));
    final isNotInitial = await isDeployed;
    return isNotInitial
        ? encode7579Call(ExecutionMode(type: CallType.call), [
          calldata,
        ], address)
        : _encodePostSetupInitCalldata(
          state.safe?.initializer,
          [calldata],
          address,
          CallType.call,
        );
  }

  Future<Uint8List> get7579ExecuteBatchCalldata({
    required List<Address> recipients,
    List<BigInt>? amountsInWei,
    List<Uint8List>? innerCalls,
  }) async {
    final calls =
        recipients
            .asMap()
            .entries
            .map(
              (entry) => entry.value.value
                  .concat(
                    intToBytes(
                      amountsInWei?[entry.key] ?? BigInt.zero,
                    ).padLeftTo32Bytes(),
                  )
                  .concat(innerCalls?[entry.key] ?? Uint8List(0)),
            )
            .toList();
    final bool isNotInitial = await isDeployed;
    return isNotInitial
        ? encode7579Call(
          ExecutionMode(type: CallType.batchcall),
          calls,
          address,
        )
        : _encodePostSetupInitCalldata(
          state.safe?.initializer,
          calls,
          address,
          CallType.batchcall,
        );
  }
}
