class ModuleInstallationException implements Exception {
  final String userFriendlyMessage;
  final dynamic originalError;

  ModuleInstallationException(this.userFriendlyMessage, this.originalError);

  @override
  String toString() => userFriendlyMessage;
}

String parseUserOperationError(dynamic error) {
  String errorString = error.toString();

  print(errorString);

  RegExp aaCodeRegex = RegExp(r'AA(\d{2})');
  Match? match = aaCodeRegex.firstMatch(errorString);

  if (match != null) {
    String aaCode = match.group(0)!;

    switch (aaCode) {
      case 'AA10':
        return 'Sender account not deployed';
      case 'AA13':
        return 'initCode failed or out of gas';
      case 'AA14':
        return 'initCode execution failed';
      case 'AA15':
        return 'initCode executed successfully but did not deploy a sender';
      case 'AA20':
        return 'Account does not support the entryPoint';
      case 'AA21':
        return 'Didn\'t pay prefund';
      case 'AA22':
        return 'UserOp expired';
      case 'AA23':
        return 'UserOp reverted';
      case 'AA24':
        return 'UserOp signature check failed';
      case 'AA25':
        return 'Invalid userOp data or signature';
      case 'AA30':
        return 'Paymaster not deployed';
      case 'AA31':
        return 'Paymaster deposit too low';
      case 'AA32':
        return 'Paymaster expired or not due to pay';
      case 'AA33':
        return 'Paymaster reverted';
      case 'AA34':
        return 'Paymaster signature check failed';
      default:
        return 'UserOperation failed with error code: $aaCode';
    }
  }

  return errorString;
}
