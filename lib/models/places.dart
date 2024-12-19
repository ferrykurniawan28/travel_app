class Places {
  int? id;
  String title;
  String description;
  String imageUrl;
  String? uid;

  Places({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'uid': uid,
    };
  }

  static Places fromMap(Object? data) {
    final map = data as Map<String, dynamic>;
    return Places(
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      uid: map['uid'],
    );
  }
}
