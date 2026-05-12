/// Lifecycle of an audio broadcast.
enum StreamStatus { starting, live, ended, failed }

/// Why a broadcast ended — set when `status` transitions to [StreamStatus.ended].
enum StreamEndReason { normal, network, killedByAdmin, error }

/// Which prayer (or non-prayer activity) the broadcast is for.
/// Drives the title chip and prayer-time badge on listener screens.
enum StreamPrayer { fajr, dhuhr, asr, maghrib, isha, jumuah, khutbah, dhikr }

/// Named `StreamRecord` (not `Stream`) to avoid collision with `dart:async`'s
/// built-in `Stream<T>` — a name we use freely throughout the codebase.
class StreamRecord {
  const StreamRecord({
    required this.id,
    required this.masjidId,
    required this.muadhinId,
    required this.muadhinName,
    required this.title,
    required this.startedAt,
    required this.status,
    this.prayer,
    this.endedAt,
    this.listenerCountPeak = 0,
    this.listenerCountCurrent = 0,
    this.endReason,
    this.replayUrl,
    this.latencyMs,
  });

  final String id;
  final String masjidId;
  final String muadhinId;

  /// Denormalised muadhin display name — the backend writes this onto the
  /// stream record when the broadcast is created so listener screens don't
  /// need a second lookup. Saves a join on every render.
  final String muadhinName;

  /// Human title shown on listener lists ("Asr Khutbah", "Fajr Remembrance",
  /// "Jumu'ah Prayer"). Set by the muadhin at broadcast start.
  final String title;

  /// Optional prayer enum if the broadcast is associated with a specific
  /// salah slot. Drives "Today's broadcasts" sorting by prayer order.
  final StreamPrayer? prayer;

  final DateTime startedAt;
  final DateTime? endedAt;
  final StreamStatus status;
  final int listenerCountPeak;
  final int listenerCountCurrent;
  final StreamEndReason? endReason;

  /// Non-null once recording is processed (B6) — listener replay reads this.
  final String? replayUrl;

  /// Most recent measured end-to-end latency in milliseconds.
  /// Drives the "LIVE · 428 ms" badge in the live player.
  final int? latencyMs;
}
