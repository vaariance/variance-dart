import 'package:flutter/material.dart';
import 'package:passkeysafe/passkeysafeutils.dart';
import 'package:passkeysafe/publickey.dart';
import 'package:webauthn/webauthn.dart';

void main() {
  runApp(const MyApp());

  final utils = PasskeyUtils("", "", "");
  utils.getPublicKeyFromBytes(Publickey.pKey);
  utils.getMessagingSignature(
      "MEUCIDvKUdPXGRDF3XhIoMEGkA2nSztsDbLoIVFSK03Htf6OAiEAqFl6IKDzAXtWmI1YDKOYD_C2CNXQp7TYfutH-fXZ6j0=");
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

final authenticator = Authenticator(true, false);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Padding(
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
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
      )),
    );
  }
}
