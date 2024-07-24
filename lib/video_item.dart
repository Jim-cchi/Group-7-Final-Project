class VideoItem {
  final String id;
  final String url;
  final String description;
  final String dateAdded;
  final String userId;
  final String user;

  VideoItem({
    required this.id,
    required this.url,
    required this.description,
    required this.dateAdded,
    required this.userId,
    required this.user,
  });

  factory VideoItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return VideoItem(
      id: id,
      url: map['url'] as String,
      description: map['description'] as String,
      dateAdded: map['dateAdded'] as String,
      userId: map['userId'] as String,
      user: map['user'] as String,
    );
  }
}
