import 'package:flutter/material.dart';


class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
      gradient: const LinearGradient(
          colors: [Colors.blue, Colors.red],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
    ));
  }
}
