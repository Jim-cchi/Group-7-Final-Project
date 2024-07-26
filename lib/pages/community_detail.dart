import 'package:flutter/material.dart';

class CommunityDetailPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final ImageProvider image;

  const CommunityDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image(
                image: image,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
    );
  }
}
