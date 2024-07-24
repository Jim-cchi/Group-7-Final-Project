import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../lists.dart';

class MyChats extends StatelessWidget {
  const MyChats({
    super.key,
    required this.colorList,
    required this.namesList,
  });

  final MyCircleAvatarList colorList;
  final MyNamesList namesList;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 20, 20, 20),
      child: ListView(
        children: [
          Container(
            height: 30,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Color.fromARGB(255, 83, 81, 81),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Search",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colorList.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(3, 3, 0, 3),
                  child: CircleAvatar(
                    backgroundImage: colorList.images[index],
                    radius: 30, // Adjust as needed
                  ),
                );
              },
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: namesList.names.length,
              itemBuilder: (context, index) {
                return MyListTile(
                  text: namesList.names[index][0],
                  subtitle: namesList.names[index][1],
                  trailingIcon: Icons.more_vert,
                );
              }),
        ],
      ),
    );
  }
}
