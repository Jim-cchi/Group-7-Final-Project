import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';

//THIS IS PROFILE
class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  Future<String> _getUsernameFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'No username found';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          const MyCircleAvatar(
            radius: 55,
          ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder<String>(
            future: _getUsernameFromSharedPref(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              } else if (snapshot.hasError) {
                return Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                );
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                );
              } else {
                return const Text(
                  "No username found",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                );
              }
            },
          ),
          const SizedBox(
            height: 25,
          ),
          const Text(
            "Your Videos:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const MyListTile(),
            ),
          ),
        ],
      ),
    );
  }
}
