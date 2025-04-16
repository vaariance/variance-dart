import 'package:flutter/material.dart';

/// Model class for signer options
class SignerOption {
  final String id;
  final String name;
  final IconData icon;
  final String description;

  SignerOption({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
  });
}