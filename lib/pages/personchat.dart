import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../lists.dart';

class MyPersonChat extends StatelessWidget {
  const MyPersonChat({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      body: ListView(
          children: [
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerRight),
            ChatBubble(message: MyNamesList.getRandomMessage(), alignment: Alignment.centerLeft),
          ],
        ),
      );
  }
}


