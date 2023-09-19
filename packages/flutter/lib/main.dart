import 'package:flutter/material.dart';
import 'package:passkeysafe/src/utils/4337/wallet.dart';
import 'package:passkeysafe/src/utils/4337/chains.dart';
import 'package:passkeysafe/src/utils/key_manager.dart';
import 'package:passkeysafe/src/utils/passkeys.dart';
import 'package:webauthn/webauthn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PasskeySafe'),
    );
  }
}

final authenticator = Authenticator(true, true);
final passkeysUtil = PassKey("https://webauthn.io", "webauthn", "webauthn.io");
final keyManager = HDKey(ksNamespace: "ksNamespace");
HDkeysInterface? hdkey;
PasskeysInterface? passkey;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final utils =
      PassKey("https://webauthn.io", "webauthn.io", "api.webauthn.io");
  final wallet = Wallet(
    chain: Chains.getChain(Chain.localhost)!,
    hdkey: HDKey(ksNamespace: "test"),
  );
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    offset: const Offset(12, 26),
                    blurRadius: 50,
                    spreadRadius: 0,
                    color: Colors.grey.withOpacity(.1)),
              ]),
              child: TextField(
                controller: usernameController,
                onChanged: (value) {
                  //Do something wi
                },
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  hintText: '',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(.75)),
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {},
                child: const Text("Register"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  wallet.userOptester();
                },
                child: const Text("Get key pair"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
