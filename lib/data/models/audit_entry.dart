enum AuditEventType {
  signIn,
  signOut,
  masjidRegistered,
  masjidApproved,
  masjidRejected,
  muadhinNominated,
  muadhinActivated,
  broadcastStarted,
  broadcastEnded,
  qrScanSubmitted,
  qrScanRejected,
  roleGranted,
  roleRevoked,
}

/// Append-only audit-log record. Backed by the `/auditLog/{eventId}`
/// Firestore collection in B-phase; written by the verification, streaming,
/// and role-management Cloud Functions.
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.eventType,
    required this.actorUserId,
    required this.timestamp,
    this.targetId,
    this.note,
  });

  final String id;
  final AuditEventType eventType;
  final String actorUserId;
  final DateTime timestamp;

  /// Optional — the entity acted upon (masjid id, muadhin id, etc.).
  final String? targetId;

  /// Optional human note rendered in the audit-log UI.
  final String? note;
}
