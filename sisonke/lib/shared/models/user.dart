class User {
  final String? id;
  final bool isGuest;
  final String? displayName;
  final DateTime? createdAt;
  final String? language;
  final String? country;

  User({
    this.id,
    required this.isGuest,
    this.displayName,
    this.createdAt,
    this.language,
    this.country,
  });

  factory User.guest() {
    return User(
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    bool? isGuest,
    String? displayName,
    DateTime? createdAt,
    String? language,
    String? country,
  }) {
    return User(
      id: id ?? this.id,
      isGuest: isGuest ?? this.isGuest,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      language: language ?? this.language,
      country: country ?? this.country,
    );
  }
}