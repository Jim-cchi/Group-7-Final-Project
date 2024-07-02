import 'package:flutter/material.dart';

class MyContainerStory extends StatelessWidget {
  const MyContainerStory({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 25, 25, 25),
      alignment:  Alignment.bottomLeft,
      margin: const EdgeInsets.all(5),
      height: 220,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}
