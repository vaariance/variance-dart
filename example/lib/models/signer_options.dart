import 'package:flutter/material.dart';
import 'package:variancedemo/constants/enums.dart';

/// Model class for signer options
class SignerOption {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final SignerTypes signers;
  final AccountType accountType;

  SignerOption(
      {required this.id,
      required this.name,
      required this.icon,
      this.description = '',
      required this.signers,
      this.accountType = AccountType.none});
}
