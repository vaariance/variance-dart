import 'package:flutter/material.dart';
import 'package:variancedemo/main.dart';
import 'package:variancedemo/variance_colors.dart';

void showSnackbar(String message) {
  var currentScaffoldMessenger = globalScaffoldMessengerKey.currentState;
  currentScaffoldMessenger?.hideCurrentSnackBar();
  currentScaffoldMessenger?.showSnackBar(SnackBar(content: Text(message)));
}

class AddressBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? textEditingController;
  final TextStyle? hintTextStyle;

  // Add an optional parameter for the initial value
  final String initialValue;

  const AddressBar({
    required this.hintText,
    this.hintTextStyle,
    this.textEditingController,
    this.initialValue = "0.0", // Provide a default initial value
    Key? key,
  }) : super(key: key);

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  bool pwdVisibility = false;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController with the initial value
    textEditingController = widget.textEditingController ??
        TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: VarianceColors.primary,
      controller: widget.textEditingController,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        fillColor: VarianceColors.secondary,
        filled: true,
        hintText: widget.hintText,
        hintStyle: widget.hintTextStyle,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10)),
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
