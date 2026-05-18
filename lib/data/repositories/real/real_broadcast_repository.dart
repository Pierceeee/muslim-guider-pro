import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/broadcast_stream.dart';
import '../broadcast_repository.dart';

class RealBroadcastRepository implements BroadcastRepository {
  RealBroadcastRepository._(this._prefs, this._cache);

  final SharedPreferences _prefs;
  final Map<String, List<BroadcastStream>> _cache; // masjidId -> list
  final Map<String, BroadcastStream?> _liveByMasjid = {};
  final Map<String, StreamController<BroadcastStream?>> _watchers = {};

  Future<void>? _pendingPersist;

  static Future<RealBroadcastRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = <String, List<BroadcastStream>>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('broadcasts_')) continue;
      final masjidId = key.substring('broadcasts_'.length);
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => BroadcastStream.fromJson(e as Map<String, dynamic>))
            .toList();
        cache[masjidId] = list;
      } catch (_) {/* ignore corrupt */}
    }
    return RealBroadcastRepository._(prefs, cache);
  }

  Future<void> _persist(String masjidId) async {
    final list = _cache[masjidId] ?? const <BroadcastStream>[];
    final encoded = jsonEncode(list.map((b) => b.toJson()).toList());
    if (_pendingPersist == null) {
      // No prior write in flight — execute immediately (no extra microtask hop).
      final write = _prefs.setString('broadcasts_$masjidId', encoded);
      _pendingPersist = write;
      await write;
    } else {
      // Chain behind the prior write so they land in order.
      final next = _pendingPersist!.then((_) async {
        await _prefs.setString('broadcasts_$masjidId', encoded);
      });
      _pendingPersist = next;
      await next;
    }
  }

  /// Closes all watcher [StreamController]s and awaits any pending persist.
  /// Safe to call multiple times.
  @override
  Future<void> dispose() async {
    for (final controller in _watchers.values) {
      await controller.close();
    }
    _watchers.clear();
    await (_pendingPersist ?? Future.value());
  }

  StreamController<BroadcastStream?> _watcher(String masjidId) {
    return _watchers.putIfAbsent(
      masjidId,
      () => StreamController<BroadcastStream?>.broadcast(),
    );
  }

  @override
  Stream<BroadcastStream?> watchCurrentLiveStream(String masjidId) async* {
    yield _liveByMasjid[masjidId];
    yield* _watcher(masjidId).stream;
  }

  @override
  List<BroadcastStream> recentBroadcasts(String masjidId, {int limit = 3}) {
    final list = (_cache[masjidId] ?? [])
        .where((s) => s.status == StreamStatus.ended)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list.take(limit).toList();
  }

  @override
  BroadcastStream? findById(String id) {
    for (final list in _cache.values) {
      for (final s in list) {
        if (s.id == id) return s;
      }
    }
    return null;
  }

  @override
  BroadcastStream startBroadcast({
    required String masjidId,
    required String muadhinId,
  }) {
    final now = DateTime.now();
    final stream = BroadcastStream(
      id: 's_${now.microsecondsSinceEpoch}',
      masjidId: masjidId,
      muadhinId: muadhinId,
      startedAt: now,
      peakListenerCount: 0,
      currentListenerCount: 0,
      status: StreamStatus.live,
    );
    final list = _cache.putIfAbsent(masjidId, () => []);
    list.add(stream);
    _liveByMasjid[masjidId] = stream;
    _watcher(masjidId).add(stream);
    _persist(masjidId); // fire-and-forget
    return stream;
  }

  @override
  BroadcastStream endBroadcast(String streamId, EndReason reason) {
    for (final masjidId in _cache.keys) {
      final list = _cache[masjidId]!;
      final idx = list.indexWhere((s) => s.id == streamId);
      if (idx == -1) continue;
      final existing = list[idx];
      final ended = existing.copyWith(
        status: StreamStatus.ended,
        endedAt: DateTime.now(),
        endReason: reason,
        currentListenerCount: 0,
      );
      list[idx] = ended;
      _liveByMasjid[masjidId] = null;
      _watcher(masjidId).add(null);
      _persist(masjidId); // fire-and-forget
      return ended;
    }
    throw StateError('Unknown stream id: $streamId');
  }
}
