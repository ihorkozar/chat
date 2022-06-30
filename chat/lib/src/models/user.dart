class User {
  String? _id;
  String username;
  String photoUrl;
  bool isActive;
  DateTime lastSeen;

  String get id => _id ?? '';

  User({
    required this.username,
    required this.photoUrl,
    required this.isActive,
    required this.lastSeen,
  });

  toJson() => {
        'username': username,
        'photo_url': photoUrl,
        'is_active': isActive,
        'last_seen': lastSeen
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        username: json['username'],
        photoUrl: json['photo_url'],
        isActive: json['is_active'],
        lastSeen: json['last_seen']);

    user._id = json['id'];

    return user;
  }
}
