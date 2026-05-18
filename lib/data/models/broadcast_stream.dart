enum StreamStatus { starting, live, ended, failed }
enum EndReason { normal, network, killedByAdmin, error }

extension _StreamStatusX on StreamStatus {
  static StreamStatus fromName(String name) =>
      StreamStatus.values.firstWhere((e) => e.name == name);
}

extension _EndReasonX on EndReason {
  static EndReason fromName(String name) =>
      EndReason.values.firstWhere((e) => e.name == name);
}

class BroadcastStream {
  const BroadcastStream({
    required this.id,
    required this.masjidId,
    required this.muadhinId,
    required this.startedAt,
    required this.peakListenerCount,
    required this.currentListenerCount,
    required this.status,
    this.endedAt,
    this.endReason,
  });

  final String id;
  final String masjidId;
  final String muadhinId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int peakListenerCount;
  final int currentListenerCount;
  final StreamStatus status;
  final EndReason? endReason;

  Duration get duration =>
      (endedAt ?? DateTime.now()).difference(startedAt);

  BroadcastStream copyWith({
    String? id,
    String? masjidId,
    String? muadhinId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? peakListenerCount,
    int? currentListenerCount,
    StreamStatus? status,
    EndReason? endReason,
  }) {
    return BroadcastStream(
      id: id ?? this.id,
      masjidId: masjidId ?? this.masjidId,
      muadhinId: muadhinId ?? this.muadhinId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      peakListenerCount: peakListenerCount ?? this.peakListenerCount,
      currentListenerCount: currentListenerCount ?? this.currentListenerCount,
      status: status ?? this.status,
      endReason: endReason ?? this.endReason,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'masjidId': masjidId,
        'muadhinId': muadhinId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'peakListenerCount': peakListenerCount,
        'currentListenerCount': currentListenerCount,
        'status': status.name,
        'endReason': endReason?.name,
      };

  factory BroadcastStream.fromJson(Map<String, dynamic> json) =>
      BroadcastStream(
        id: json['id'] as String,
        masjidId: json['masjidId'] as String,
        muadhinId: json['muadhinId'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        peakListenerCount: (json['peakListenerCount'] as num?)?.toInt() ?? 0,
        currentListenerCount: (json['currentListenerCount'] as num?)?.toInt() ?? 0,
        status: _StreamStatusX.fromName(json['status'] as String),
        endReason: json['endReason'] != null
            ? _EndReasonX.fromName(json['endReason'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BroadcastStream &&
          other.id == id &&
          other.masjidId == masjidId &&
          other.muadhinId == muadhinId &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.peakListenerCount == peakListenerCount &&
          other.currentListenerCount == currentListenerCount &&
          other.status == status &&
          other.endReason == endReason);

  @override
  int get hashCode => Object.hash(
        id, masjidId, muadhinId, startedAt, endedAt,
        peakListenerCount, currentListenerCount, status, endReason,
      );
}
