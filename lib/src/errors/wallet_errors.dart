part of '../../variance.dart';

class EstimateError extends Error {
  final String message;

  final UserOperation operation;

  EstimateError(this.message, this.operation);

  @override
  String toString() {
    return '''
        Error estimating user operation gas! Failed with error: $message
        --------------------------------------------------
       User operation: ${operation.toJson()}.
    ''';
  }
}

class NonceError extends Error {
  final String message;
  final EthereumAddress? address;

  NonceError(this.message, this.address);

  @override
  String toString() {
    return '''
        Error fetching user account nonce for address  ${address?.hex}! 
        --------------------------------------------------
        Failed with error: $message  
      ''';
  }
}

class SendError extends Error {
  final String message;
  final UserOperation operation;

  SendError(this.message, this.operation);

  @override
  String toString() {
    return '''
        Error sending user operation! Failed with error: $message
        --------------------------------------------------
       User operation: ${operation.toJson()}. 
    ''';
  }
}
