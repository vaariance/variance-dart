class UserOperationResponse {
  final bool success;
  final String? message;
  final String? transactionHash;

  UserOperationResponse({
    required this.success,
    this.message,
    this.transactionHash,
  });
}