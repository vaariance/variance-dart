import 'package:flutter/material.dart';

class OptionsBottomSheet extends StatelessWidget {
  const OptionsBottomSheet({super.key, this.options = const []});
  final List<String> options;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(
          'Option $index',
          style: TextStyle(color: Colors.grey[200]),
        ),
        onTap: () => Navigator.pop(context),
      ),
      itemCount: 5,
    );
  }
}
