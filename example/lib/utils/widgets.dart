 import 'package:flutter/material.dart';
import 'package:variancedemo/main.dart';

void showSnackbar(String message) {
    var currentScaffoldMessenger = globalScaffoldMessengerKey.currentState;
    currentScaffoldMessenger?.hideCurrentSnackBar();
    currentScaffoldMessenger?.showSnackBar(SnackBar(content: Text(message)));
  }