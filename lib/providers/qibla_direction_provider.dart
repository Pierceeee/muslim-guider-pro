import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/qibla_service.dart';

final qiblaServiceProvider = Provider<QiblaService>((_) => QiblaService());

final qiblaDirectionProvider =
    StreamProvider.family<double, ({double lat, double lng})>((ref, latLng) {
  return ref.watch(qiblaServiceProvider).bearingFor(
    userLat: latLng.lat,
    userLng: latLng.lng,
  );
});
