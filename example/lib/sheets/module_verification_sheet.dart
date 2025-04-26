import 'package:flutter/material.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

class ModuleVerificationSheet extends StatefulWidget {
  const ModuleVerificationSheet({
    super.key,
  });

  @override
  ModuleVerificationSheetState createState() => ModuleVerificationSheetState();
}

class ModuleVerificationSheetState extends State<ModuleVerificationSheet> {
  ModuleType? selectedType;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contextController = TextEditingController();
  bool hasContext = false;

  @override
  void dispose() {
    addressController.dispose();
    contextController.dispose();
    super.dispose();
  }

  void _handleVerify(BuildContext context) {
    if (selectedType == null || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a module type and enter an address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Uint8List? contextData;
    if (hasContext && contextController.text.isNotEmpty) {
      contextData = hexToBytes(contextController.text);
    }

    final result = (
      selectedType,
      EthereumAddress.fromHex(addressController.text),
      contextData
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A3C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verify Module Installation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[200],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<ModuleType>(
              value: selectedType,
              hint: Text('Select Module Type',
                  style: TextStyle(color: Colors.grey[400])),
              dropdownColor: const Color(0xFF2A2A3C),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                filled: true,
                fillColor: const Color(0xFF1F1F2C),
              ),
              style: TextStyle(color: Colors.grey[200]),
              items: ModuleType.values.map((type) {
                return DropdownMenuItem<ModuleType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Module Address',
                labelStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                filled: true,
                fillColor: const Color(0xFF1F1F2C),
                prefixIcon: Icon(Icons.link, color: Colors.grey[400]),
              ),
              style: TextStyle(color: Colors.grey[200]),
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              value: hasContext,
              onChanged: (value) {
                setState(() {
                  hasContext = value;
                });
              },
              title: Text(
                'Include Context Data',
                style: TextStyle(color: Colors.grey[200]),
              ),
              subtitle: Text(
                'Some modules require additional context for verification',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              activeColor: const Color(0xFF663399),
            ),
            if (hasContext) ...[
              const SizedBox(height: 15),
              TextFormField(
                controller: contextController,
                decoration: InputDecoration(
                  labelText: 'Context Data (hex)',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1F1F2C),
                  prefixIcon: Icon(Icons.data_array, color: Colors.grey[400]),
                ),
                style: TextStyle(color: Colors.grey[200]),
              ),
            ],
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleVerify(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF663399),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Verify Installation',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
