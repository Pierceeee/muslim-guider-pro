class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.at,
    required this.actorId,
    required this.action,
    this.targetId,
    this.meta = const {},
  });

  final String id;
  final DateTime at;
  final String actorId;
  final String action;
  final String? targetId;
  final Map<String, dynamic> meta;
}
