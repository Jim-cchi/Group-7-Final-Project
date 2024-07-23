import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../lists.dart';
import 'pages.dart';

class MyActivity extends StatefulWidget {
  const MyActivity({super.key});

  @override
  State<MyActivity> createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  int currentPageIndex = 0;

  List<Widget> pages = [
    MyChats(colorList: MyCircleAvatarList(), namesList: MyNamesList()),
    const MyHighlights(),
    const MyPeople(),
  ];

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      body: pages[currentPageIndex],
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        child: ListView(
          children: const [
            SizedBox(
              height: 60,
              child: DrawerHeader(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Jim Raffael Alvarez",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            MyListTile(
              leadingIcon: Icons.chat_bubble,
              text: "Chats",
              trailingIcon: Icons.looks_6,
              trailingIconColor: Colors.blue,
            ),
            MyListTile(
              leadingIcon: Icons.shopping_cart,
              text: "Marketplace",
            ),
            MyListTile(
              leadingIcon: Icons.message,
              text: "Message requests",
            ),
            MyListTile(
              leadingIcon: Icons.mail,
              text: "Archive",
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "  Communities",
                style: TextStyle(
                  color: Color.fromARGB(255, 112, 114, 114),
                ),
              ),
              Text(
                "Edit  ",
                style: TextStyle(color: Colors.blue),
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? const TextStyle(color: Colors.blue)
                : const TextStyle(color: Colors.white),
          ),
        ),
        child: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            backgroundColor: const Color.fromARGB(255, 20, 20, 20),
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.chat_bubble,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                ),
                label: 'Chats',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.bolt,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.bolt,
                  color: Colors.white,
                ),
                label: 'Highlights',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.group,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.group,
                  color: Colors.white,
                ),
                label: 'People',
              ),
            ]),
      ),
    );
    return scaffold;
  }
}
