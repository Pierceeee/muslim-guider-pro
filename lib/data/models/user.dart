enum UserRole { listener, muadhin, admin }

class User {
  const User({
    required this.id,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.masjidId,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final String? masjidId;

  User copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    String? masjidId,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      masjidId: masjidId ?? this.masjidId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other.displayName == displayName &&
          other.avatarUrl == avatarUrl &&
          other.role == role &&
          other.masjidId == masjidId);

  @override
  int get hashCode => Object.hash(id, displayName, avatarUrl, role, masjidId);
}
