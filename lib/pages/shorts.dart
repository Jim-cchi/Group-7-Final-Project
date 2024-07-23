import 'package:flutter/material.dart';

class MyShorts extends StatefulWidget {
  const MyShorts({super.key});

  @override
  State<MyShorts> createState() => _MyShortsState();
}

class _MyShortsState extends State<MyShorts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
          child: Column(
        children: [
          Text("yes"),
        ],
      )),
    );
  }
}
