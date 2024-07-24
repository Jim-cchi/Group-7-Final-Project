import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String userEmail = "User";

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? "User";
    });
  }

  List<Widget> pages = [
    MyChats(colorList: MyCircleAvatarList(), namesList: MyNamesList()),
    const MyHighlights(),
    const MyAddShort(),
    const MyPeople(),
    const MyShorts(),
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
          children: [
            SizedBox(
              height: 60,
              child: DrawerHeader(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    title: Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const MyListTile(
              leadingIcon: Icons.chat_bubble,
              text: "Chats",
              trailingIcon: Icons.looks_6,
              trailingIconColor: Colors.blue,
            ),
            const MyListTile(
              leadingIcon: Icons.shopping_cart,
              text: "Marketplace",
            ),
            const MyListTile(
              leadingIcon: Icons.message,
              text: "Message requests",
            ),
            const MyListTile(
              leadingIcon: Icons.mail,
              text: "Archive",
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
              if (index == 2) {
                // Plus icon is at index 2
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyAddShort()),
                );
              } else {
                setState(() {
                  currentPageIndex = index;
                });
              }
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
                icon: SizedBox(
                  width: 40, // adjust the width
                  height: 40, // adjust the height
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 40, // adjust the icon size
                  ),
                ),
                label: '',
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
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.video_library,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.video_library,
                  color: Colors.white,
                ),
                label: 'Shorts',
              ),
            ]),
      ),
    );
    return scaffold;
  }
}
