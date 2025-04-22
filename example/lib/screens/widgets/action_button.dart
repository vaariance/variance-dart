import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.child, required this.onPressed});
  final void Function() onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF663399)),
      child: child,
    );
  }
}

Future showOptionSheets(BuildContext context, Widget child) {
 return showModalBottomSheet(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    isDismissible: false,
    isScrollControlled: true,
     constraints: const BoxConstraints(maxHeight: 400),
    context: context,
    backgroundColor:  Color(0xFF2A2A3C),
    builder: (context) => child,
  );
}

