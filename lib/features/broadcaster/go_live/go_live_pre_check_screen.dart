import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/router/route_names.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/repository_providers.dart';
import 'go_live_controller.dart';
import 'widgets/check_card.dart';

class GoLivePreCheckScreen extends ConsumerStatefulWidget {
  const GoLivePreCheckScreen({super.key});

  @override
  ConsumerState<GoLivePreCheckScreen> createState() =>
      _GoLivePreCheckScreenState();
}

class _GoLivePreCheckScreenState extends ConsumerState<GoLivePreCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goLiveControllerProvider.notifier).runFakeChecks();
      _requestMic();
    });
  }

  Future<void> _requestMic() async {
    final controller = ref.read(goLiveControllerProvider.notifier)
      ..setMic(CheckStatus.checking);
    try {
      final status = await Permission.microphone.request();
      controller.setMic(
        status.isGranted ? CheckStatus.ok : CheckStatus.failed,
      );
    } catch (_) {
      controller.setMic(CheckStatus.failed);
    }
  }

  Future<void> _onContinue() async {
    final user = ref.read(currentUserProvider).value;
    final masjid = ref.read(currentMasjidProvider);
    if (user == null || masjid == null) return;
    final stream = ref
        .read(broadcastRepositoryProvider)
        .startBroadcast(masjidId: masjid.id, muadhinId: user.id);
    if (!mounted) return;
    context.pushReplacement('${RouteNames.livePath}/${stream.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goLiveControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Broadcast Check')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckCard(
                icon: Icons.mic,
                title: 'Microphone',
                subtitle: state.mic == CheckStatus.failed
                    ? 'Permission denied — open Settings to enable'
                    : 'Required for the ambient meter',
                status: state.mic,
                onRetry: state.mic == CheckStatus.failed ? openAppSettings : null,
              ),
              const SizedBox(height: 12),
              CheckCard(
                icon: Icons.wifi,
                title: 'Network',
                subtitle: 'Connectivity to AWS Chime SFU',
                status: state.network,
              ),
              const SizedBox(height: 12),
              CheckCard(
                icon: Icons.place,
                title: 'Inside masjid radius',
                subtitle:
                    'Geofence verification will be real once GPS lands',
                status: state.geofence,
              ),
              const Spacer(),
              if (kDebugMode && state.mic != CheckStatus.ok)
                TextButton(
                  onPressed: () => ref
                      .read(goLiveControllerProvider.notifier)
                      .setMic(CheckStatus.ok),
                  child: const Text('Debug: force mic OK'),
                ),
              FilledButton(
                onPressed: state.allOk ? _onContinue : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
