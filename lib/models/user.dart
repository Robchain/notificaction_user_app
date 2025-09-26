class User {
  final String username;
  final String name;
  final DateTime createdAt;

  User({
    required this.username,
    required this.name,
    required this.createdAt,
  });

  User copyWith({
    String? username,
    String? name,
    DateTime? createdAt,
  }) {
    return User(
      username: username ?? this.username,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(username: $username, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.username == username &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => username.hashCode ^ name.hashCode ^ createdAt.hashCode;
}