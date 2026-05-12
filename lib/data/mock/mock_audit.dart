import '../models/audit_entry.dart';

/// Audit entries used by the broadcaster's audit-log screen (F5) and the
/// admin dashboard (B-phase). Stored as a top-level `final` because
/// `DateTime` is not const-constructible.
final mockAuditEntries = <AuditEntry>[
  AuditEntry(
    id: 'audit-1',
    eventType: AuditEventType.signIn,
    actorUserId: 'user-yusuf',
    timestamp: DateTime(2026, 5, 13, 5, 0),
  ),
  AuditEntry(
    id: 'audit-2',
    eventType: AuditEventType.broadcastStarted,
    actorUserId: 'user-yusuf',
    targetId: 'stream-abrar-past-fajr',
    timestamp: DateTime(2026, 5, 13, 5, 12),
    note: 'Fajr broadcast started · Masjid Al-Abrar',
  ),
  AuditEntry(
    id: 'audit-3',
    eventType: AuditEventType.broadcastEnded,
    actorUserId: 'user-yusuf',
    targetId: 'stream-abrar-past-fajr',
    timestamp: DateTime(2026, 5, 13, 5, 18),
    note: 'Fajr broadcast ended · 6m 24s · 832 peak',
  ),
];
