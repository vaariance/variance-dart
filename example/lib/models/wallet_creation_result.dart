/// Model to hold wallet creation result information
class WalletCreationResult {
  final bool success;
  final String errorMessage;
  final dynamic wallet;
  final String address;

  WalletCreationResult({
    required this.success,
    this.errorMessage = '',
    this.wallet,
    this.address = '',
  });
}