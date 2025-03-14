part of 'interface.dart';

abstract class ExecutorModuleInterface extends Base7579ModuleInterface {
  ExecutorModuleInterface(super.wallet);

  // calls the executor module to execute a function call on the account
  // entrypoint => account (execute) -> module (execute) -> adapter (executeFromExecutor) ->
  Future<UserOperationResponse> execute(Uint8List encodedFunctionCall) {
    final innerCallData = Contract.encodeFunctionCall(
        'execute', address, Safe7579Abis.get('iModule'), [encodedFunctionCall]);
    return wallet.sendTransaction(wallet.address, innerCallData);
  }
}
