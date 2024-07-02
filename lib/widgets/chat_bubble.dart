import 'package:flutter/material.dart';


class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key, required this.message, required this.alignment,
  });

  final String message;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: alignment == Alignment.centerRight ? Colors.blue : const Color.fromARGB(255, 7, 3, 58),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}