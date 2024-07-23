import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    this.text = "",
  });

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        fixedSize: WidgetStatePropertyAll(
          Size(40, 20),
        ),
      ),
      child: Text(text),
    );
  }
}
