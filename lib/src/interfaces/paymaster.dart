part of 'interfaces.dart';

abstract class PaymasterBase {
  /// Sets the context data for the Paymaster.
  ///
  /// [context] is a map containing the context data to be set.
  set paymasterContext(Map<String, String>? context);

  /// Sets the address of the Paymaster.
  ///
  /// [address] is the address of the Paymaster.
  set paymasterAddress(Address? address);

  /// Intercepts a [UserOperation] and sponsors it with the Paymaster.
  ///
  /// [operation] is the [UserOperation] to be sponsored.
  ///
  /// Returns a [Future] that resolves to the sponsored [UserOperation].
  ///
  /// This method calls the `sponsorUserOperation` method to get the Paymaster
  /// response, and then creates a new [UserOperation] with the updated
  /// Paymaster data and gas limits.
  Future<UserOperation> sponsorUserOperation(UserOperation operation);
}
