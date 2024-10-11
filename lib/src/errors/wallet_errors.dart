part of '../../variance_dart.dart';

class GasEstimationError extends Error {
  final String message;
  final UserOperation operation;

  GasEstimationError(this.message, this.operation);

  @override
  String toString() {
    return '''
        Error estimating user operation gas! Failed with error: $message
        --------------------------------------------------
       User operation: ${operation.toJson()}.
    ''';
  }
}

class InvalidBundlerMethod extends Error {
  final String message = 'Invalid bundler method!';
  final String? method;

  InvalidBundlerMethod(this.method);

  @override
  String toString() {
    return '''
        $message
        --------------------------------------------------
        method ::'$method':: is not supported by the bundler.
    ''';
  }
}

class InvalidBundlerUrl extends Error {
  final String message = 'Invalid bundler url!';
  final String? url;

  InvalidBundlerUrl(this.url);

  @override
  String toString() {
    return '''
        $message
        --------------------------------------------------
        Provided bundler url: $url
    ''';
  }
}

class InvalidFactoryAddress extends Error {
  final EthereumAddress? address;
  final String message = 'Invalid account factory address!';

  InvalidFactoryAddress(this.address);

  @override
  String toString() {
    return '''
        $message
        --------------------------------------------------
        Provided factory address: $address
    ''';
  }
}

class InvalidJsonRpcUrl extends Error {
  final String message = 'Invalid json rpc url!';
  final String? url;

  InvalidJsonRpcUrl(this.url);

  @override
  String toString() {
    return '''
        $message
        --------------------------------------------------
        Provided json rpc url: $url
    ''';
  }
}

class InvalidPaymasterUrl extends Error {
  final String message = 'Invalid paymaster url!';
  final String? url;

  InvalidPaymasterUrl(this.url);

  @override
  String toString() {
    return '''
        $message
        --------------------------------------------------
        Provided paymaster url: $url
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

class RangeOutOfBounds extends Error {
  final String? message;
  final int? start;
  final int? end;

  RangeOutOfBounds(this.message, this.start, this.end);

  @override
  String toString() {
    return '''
        $message
        --------------------------------------------------
        only start ::'$start':: and end ::'$end':: is permissible.
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

class FetchBalanceError extends Error {
  final String message;
  final EthereumAddress? address;

  FetchBalanceError(this.message, this.address);

  @override
  String toString() {
    return '''
        Error fetching user account balance for address  ${address?.hex}! 
        --------------------------------------------------
        Failed with error: $message  
      ''';
  }
}
