class Masjid {
  const Masjid({
    required this.id,
    required this.name,
    required this.city,
    required this.authorisedMuadhinIds,
    this.latitude = 21.4225,
    this.longitude = 39.8262,
    this.heroImageUrl,
    this.isBroadcasting = false,
    this.currentStreamId,
  });

  final String id;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final String? heroImageUrl;
  final List<String> authorisedMuadhinIds;
  final bool isBroadcasting;
  final String? currentStreamId;

  Masjid copyWith({
    String? id,
    String? name,
    String? city,
    double? latitude,
    double? longitude,
    String? heroImageUrl,
    List<String>? authorisedMuadhinIds,
    bool? isBroadcasting,
    String? currentStreamId,
  }) {
    return Masjid(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      authorisedMuadhinIds: authorisedMuadhinIds ?? this.authorisedMuadhinIds,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      currentStreamId: currentStreamId ?? this.currentStreamId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Masjid &&
          other.id == id &&
          other.name == name &&
          other.city == city &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.heroImageUrl == heroImageUrl &&
          _listEq(other.authorisedMuadhinIds, authorisedMuadhinIds) &&
          other.isBroadcasting == isBroadcasting &&
          other.currentStreamId == currentStreamId);

  @override
  int get hashCode => Object.hash(
        id, name, city, latitude, longitude, heroImageUrl,
        Object.hashAll(authorisedMuadhinIds),
        isBroadcasting, currentStreamId,
      );

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
