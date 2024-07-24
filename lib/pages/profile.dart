import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  Future<String?> _getUserIdFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<List<Map<String, dynamic>>> _getUserVideos() async {
    final userId = await _getUserIdFromSharedPref();
    if (userId == null) {
      return [];
    }

    final databaseReference = FirebaseDatabase.instance.ref('shorts');
    final snapshot =
        await databaseReference.orderByChild('userId').equalTo(userId).once();

    final videos = <Map<String, dynamic>>[];
    if (snapshot.snapshot.value != null) {
      final videoData =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      videoData.forEach((key, value) {
        final video = Map<String, dynamic>.from(value);
        videos.add(video);
      });
    }
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const MyCircleAvatar(radius: 55),
            const SizedBox(height: 10),
            FutureBuilder<String?>(
              future: _getUserIdFromSharedPref(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.white);
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red));
                } else if (snapshot.hasData) {
                  return Text(
                    "User ID: ${snapshot.data}",
                    style: const TextStyle(color: Colors.white),
                  );
                } else {
                  return const Text(
                    "No user ID found",
                    style: TextStyle(color: Colors.white),
                  );
                }
              },
            ),
            const SizedBox(height: 25),
            const Text(
              "Your Videos:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getUserVideos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red));
                  } else if (snapshot.hasData) {
                    final videos = snapshot.data!;
                    if (videos.isEmpty) {
                      return const Text("No videos found",
                          style: TextStyle(color: Colors.white));
                    }
                    return ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return ListTile(
                          title: Text(
                            video['description'] ?? 'No description',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            video['dateAdded'] ?? 'No date',
                            style: const TextStyle(color: Colors.white),
                          ),
                          leading: video['url'] != null
                              ? Image.network(video['url'])
                              : const Icon(Icons.video_library,
                                  color: Colors.white),
                        );
                      },
                    );
                  } else {
                    return const Text("No videos found",
                        style: TextStyle(color: Colors.white));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
