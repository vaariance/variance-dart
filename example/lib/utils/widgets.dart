import 'package:flutter/material.dart';
import 'package:variancedemo/main.dart';
import 'package:variancedemo/models/signer_options.dart';
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


class AccountDropdown extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<SignerOption> options;
  final String? selectedSigner;
  final Function(SignerOption) onSelect;

  const AccountDropdown({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isExpanded,
    required this.onToggle,
    required this.options,
    required this.selectedSigner,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header button
          Container(
            height: 65,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: isExpanded
                      ? const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  )
                      : BorderRadius.circular(16),
                  side: BorderSide(color: color, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(icon, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: color,
                  ),
                ],
              ),
            ),
          ),

          // Expanded options
          if (isExpanded)
            _buildExpandedOptions(),
        ],
      ),
    );
  }

  Widget _buildExpandedOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: options.map((option) {
          final isSelected = selectedSigner == option.id;
          return InkWell(
            onTap: () => onSelect(option),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    option.icon,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (option.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              option.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
