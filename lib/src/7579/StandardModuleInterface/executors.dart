part of 'interface.dart';

abstract class ExecutorModuleInterface extends Base7579ModuleInterface {
  Future<UserOperationResponse> execute(Uint8List encodedFunctionCall);
}
