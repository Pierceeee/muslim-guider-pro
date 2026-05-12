import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/audit_entry.dart';

void main() {
  test('AuditEntry stores actor and action', () {
    final e = AuditEntry(
      id: 'a1',
      at: DateTime(2026, 5, 13),
      actorId: 'u1',
      action: 'BROADCAST_STARTED',
      targetId: 's1',
      meta: const {'masjidId': 'm1'},
    );
    expect(e.action, 'BROADCAST_STARTED');
    expect(e.meta['masjidId'], 'm1');
  });
}
