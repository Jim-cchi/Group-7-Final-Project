import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../lists.dart';

class MyHighlights extends StatelessWidget {
  const MyHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    MyNamesList namesList = MyNamesList();
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: namesList.names.length,
        itemBuilder: (context, index) {
          return MyContainerStory(
            text: namesList.names[index][0],
          );
        },
      ),
    );
  }
}
