import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/widgets.dart';

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
          MyElevatedButton(
            text: "meera",
          )
        ],
      )),
    );
  }
}
