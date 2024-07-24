import 'package:flutter/material.dart';
import '../lists.dart';
import '../widgets/widgets.dart';

//THIS IS PROFILE

class MyPeople extends StatelessWidget {
  const MyPeople({super.key});

  @override
  Widget build(BuildContext context) {
    MyNamesList namesList = MyNamesList();
    return ListView.builder(
        shrinkWrap: true,
        itemCount: namesList.names.length,
        itemBuilder: (context, index) {
          return MyListTile(
            text: namesList.names[index][0],
            trailingIcon: Icons.circle,
            trailingIconColor: Colors.green,
          );
        });
  }
}
