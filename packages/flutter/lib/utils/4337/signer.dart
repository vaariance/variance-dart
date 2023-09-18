import 'package:passkeysafe/utils/common.dart';
import 'package:passkeysafe/utils/key_manager.dart';
import 'package:passkeysafe/utils/passkeys.dart';

enum SignerType {
  passkeys,
  hdkeys,
}

class Signer {
  PasskeysInterface? passkey;
  HDkeysInterface? hdkey;
  SignerType defaultSigner;

  Signer({this.passkey, this.hdkey, SignerType signer = SignerType.hdkeys})
      : assert(passkey != null || hdkey != null),
        defaultSigner = signer;

  void setDefaultSigner(SignerType type) {
    defaultSigner = type;
  }

  Future<T> sign<T>(dynamic hash, {int? index, String? id}) async {
    switch (defaultSigner) {
      case SignerType.passkeys:
        require(
            id != null && id.isNotEmpty, "Passkey Credential ID is required");
        return await passkey!.sign(hash, id!) as T;
      default:
        return await hdkey!.sign(hash, index: index, id: id) as T;
    }
  }
}
