import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    this.onPressed,
    this.text = "",
  });

  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        fixedSize: WidgetStatePropertyAll(
          Size(100, 50),
        ),
      ),
      child: Text(text),
    );
  }
}
