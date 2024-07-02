import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../lists.dart';

class MyPersonChat extends StatelessWidget {
  const MyPersonChat({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        title: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      body: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return ChatBubble(
              message: MyNamesList.getRandomMessage(),
              alignment: index % 2 == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
            );
          },
        ),
      );
  }
}


