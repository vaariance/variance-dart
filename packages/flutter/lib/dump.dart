// Future<PassKeyPair> getPassKeyPair(List<String> credentialIds) async {
//     final options = _opts;
//     options.type = "webauthn.get";
//     final hash = clientDataHash32(options);
//     final assertion = await _authenticate(credentialIds, hash, true);
//     final credId = assertion.selectedCredentialId;
//     return PassKeyPair(
//       hexlify(keccak256(credId)),
//       base64Url.encode(assertion.selectedCredentialId),
//       "0x0",
//       "0x0",
//       "",
//       "",
//       DateTime.now(),
//     );
//   }