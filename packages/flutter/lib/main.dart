import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:passkeysafe/utils/passkeys.dart';
import 'package:webauthn/webauthn.dart';
import 'dart:developer';

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
final passkeysUtil =
    PasskeyUtils("https://webauthn.io", "webauthn", "webauthn.io");

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final utils =
      PasskeyUtils("https://webauthn.io", "webauthn.io", "api.webauthn.io");
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
                onPressed: () async {
                  final account =
                      await passkeysUtil.register("Gef", true); // log(account);
                },
                child: const Text("Register"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  final signatureBytes = base64Url.decode(
                      'MEUCIDvKUdPXGRDF3XhIoMEGkA2nSztsDbLoIVFSK03Htf6OAiEAqFl6IKDzAXtWmI1YDKOYD_C2CNXQp7TYfutH-fXZ6j0=');
                  final result =
                      await passkeysUtil.getMessagingSignature(signatureBytes);
                  log(result[0]);
                  log(result[1]);
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
