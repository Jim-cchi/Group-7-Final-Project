import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../lists.dart';
import '../widgets/my_highlights_list_tile.dart';

class MyHighlights extends StatelessWidget {
  const MyHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    MyNamesList namesList = MyNamesList();
    return ListView(
      children: [
        Container(
          color: const Color.fromARGB(255, 25, 25, 25),
          child: SizedBox(
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
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: namesList.names.length,
          itemBuilder: (context, index) {
          return MyHighlightListTile(
            text: namesList.names[index][0],
            subtitle: namesList.names[index][1],
          );
        })
      ],
    );
  }
}
