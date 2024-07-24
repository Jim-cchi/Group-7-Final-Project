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

  final List<String> _titles = [
    'Shorts',
    'Likes',
    'Add Shorts',
    'Chats',
    'Profile',
  ];

  List<Widget> pages = [
    const MyShorts(),
    const MyLikes(),
    const MyAddShort(),
    MyChats(colorList: MyCircleAvatarList(), namesList: MyNamesList()),
    const MyProfile(),
  ];
  List<Widget> _buildCommunityList() {
    MyNamesList myNamesLists = MyNamesList();
    MySquareAvatarList mySquareAvatarList = MySquareAvatarList();
    List<Widget> communityTiles = [];

    for (int i = 0; i < myNamesLists.communities.length; i++) {
      if (i < MySquareAvatarList().images_.length) {
        communityTiles.add(
          ListTile(
            leading: CircleAvatar(
              backgroundImage: mySquareAvatarList.images_[i],
            ),
            title: Text(
              myNamesLists.communities[i][0],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              myNamesLists.communities[i][1],
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Handle tap
            },
          ),
        );
      }
    }

    return communityTiles;
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[currentPageIndex],
          style: const TextStyle(color: Colors.white),
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
                    trailing: IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_outlined),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              ],
            ),
            ..._buildCommunityList(), // Add the community tiles here
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
                  Icons.video_library,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.video_library,
                  color: Colors.white,
                ),
                label: 'Shorts',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.favorite_outlined,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.favorite_outlined,
                  color: Colors.white,
                ),
                label: 'Likes',
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
                  Icons.person,
                  color: Colors.blue,
                ),
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                label: 'Profile',
              ),
            ]),
      ),
    );
    return scaffold;
  }
}
