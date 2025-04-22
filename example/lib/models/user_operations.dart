
import '../constants/enums.dart';

class UserOperationResponse {
  UserOperationResponse({
    required this.success,
    this.message,
    this.transactionHash,
    this.type = ModuleType.none,
  });

  final bool success;
  final String? message;
  final String? transactionHash;
  final ModuleType type;
}