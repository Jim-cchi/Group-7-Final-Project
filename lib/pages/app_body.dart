import 'package:flutter/material.dart';
import 'package:myapp/pages/community_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';
import '../lists.dart';
import 'pages.dart';
import 'shorts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyActivity extends StatefulWidget {
  const MyActivity({super.key});

  @override
  State<MyActivity> createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  int currentPageIndex = 0;
  String userEmail = "User";
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadProfileImageUrl();
  }

  void _loadProfileImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedProfileImageUrl = prefs.getString('profileImageUrl');

    if (storedProfileImageUrl != null) {
      setState(() {
        _profileImageUrl = storedProfileImageUrl;
      });
    } else {
      // Fetch from Firebase if not available in SharedPreferences
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<Object?, dynamic>;
        setState(() {
          _profileImageUrl =
              userData['profileImageUrl'] ?? 'https://via.placeholder.com/150';
        });

        // Save the URL to SharedPreferences for quicker access next time
        await prefs.setString('profileImageUrl', _profileImageUrl!);
      }
    }
  }

  void _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? "User";
    });

    // Move SnackBar display here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully logged in as $userEmail',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.amber, fontSize: 16),
          ),
        ),
      );
    });

    debugPrint('Loaded userEmail: $userEmail'); // Debug print
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
    MyNamesList myNamesList = MyNamesList();
    MySquareAvatarList mySquareAvatarList = MySquareAvatarList();
    List<Widget> communityTiles = [];

    for (int i = 0; i < myNamesList.communities.length; i++) {
      communityTiles.add(
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(
                8.0), // Adjust border radius for rounded corners
            child: Image(
              image: mySquareAvatarList.images[i],
              width: 50.0,
              height: 50.0,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            myNamesList.communities[i][0],
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            MyNamesList.getRandomMessage(),
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityDetailPage(
                  title: myNamesList.communities[i][0],
                  subtitle: MyNamesList.getRandomMessage(),
                  image: mySquareAvatarList.images[i],
                ),
              ),
            );
          },
        ),
      );
    }

    return communityTiles;
  }
  void _onDrawerChatsTap() {
    setState(() {
      currentPageIndex = 3; // Change to the index of the "Chats" page
    });
    Navigator.of(context).pop(); // Close the drawer
  }
  Future<void> _confirmLogout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
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
              height: 75,
              child: DrawerHeader(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  //use the new profile picture here
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        _profileImageUrl ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    title: Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout_outlined),
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
              onTap: _onDrawerChatsTap, // Set the onTap callback
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
