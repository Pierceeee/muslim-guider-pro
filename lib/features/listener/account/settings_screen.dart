import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/prayer_times.dart';
import '../../../data/models/user_preferences.dart';
import '../../../data/providers/listener_providers.dart';
import '../../../data/providers/repository_providers.dart';

/// Recreates `prototype/screens/settings.html`.
///
/// Data:
///   • `userPreferencesProvider` — toggles + language/hijri pickers
///   • `scheduleRepositoryProvider` — calculation method (re-read from
///     the same source the dashboard uses, so a change here propagates)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  CalculationMethod? _method;
  bool _methodLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethod();
  }

  Future<void> _loadMethod() async {
    final repo = ref.read(scheduleRepositoryProvider);
    final m = await repo.getCurrentMethod();
    if (!mounted) return;
    setState(() {
      _method = m;
      _methodLoading = false;
    });
  }

  Future<void> _setMethod(CalculationMethod m) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.setCurrentMethod(m);
    // Invalidate the schedule provider so the dashboard re-fetches with the
    // new method.
    ref.invalidate(todaysPrayerScheduleProvider);
    if (!mounted) return;
    setState(() => _method = m);
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ListenerRoute.nameProfile);
    }
  }

  void _info(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(
          'Sign out?',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        content: Text(
          'You\'ll need to sign back in to listen to live broadcasts and '
          'see your verified masjids.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style:
                  AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Sign out',
              style:
                  AppTypography.labelCaps.copyWith(color: AppColors.liveRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      _info('Signed out. (Real sign-in flow lands in F3.)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsCtrl = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _BackgroundGlows()),
          SafeArea(
            child: Column(
              children: <Widget>[
                _Header(onBack: _back),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.containerMargin,
                      0,
                      AppSpacing.containerMargin,
                      40,
                    ),
                    children: <Widget>[
                      // ─── PRAYER & BROADCAST ───────────────────────────
                      _Section(
                        label: 'PRAYER & BROADCAST',
                        children: <Widget>[
                          _ToggleRow(
                            title: 'Auto-play nearest Athan',
                            subtitle:
                                'Play the closest masjid at prayer time',
                            value: prefs.autoPlayNearestAthan,
                            onChanged: prefsCtrl.setAutoPlayNearestAthan,
                          ),
                          const _Divider(),
                          _ToggleRow(
                            title: 'Background proximity',
                            subtitle: 'Switch broadcasts as you move',
                            value: prefs.backgroundProximity,
                            onChanged: prefsCtrl.setBackgroundProximity,
                          ),
                          const _Divider(),
                          _ToggleRow(
                            title: 'Prayer reminders',
                            subtitle: '30 min before each prayer',
                            value: prefs.prayerReminders,
                            onChanged: prefsCtrl.setPrayerReminders,
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Calculation method',
                            subtitle: _methodLoading
                                ? 'Loading…'
                                : _methodLabel(_method!),
                            subtitleGold: true,
                            onTap: () => _openMethodPicker(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      // ─── SECURITY ─────────────────────────────────────
                      _Section(
                        label: 'SECURITY',
                        children: <Widget>[
                          _ToggleRow(
                            title: 'Face ID',
                            subtitle: 'Unlock & authorize broadcasts',
                            value: prefs.faceId,
                            onChanged: prefsCtrl.setFaceId,
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Two-factor authentication',
                            subtitle: 'Authenticator app · TOTP',
                            onTap: () => _info(
                              'TOTP MFA setup lands in B-phase security work.',
                            ),
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Connected devices',
                            subtitle: '2 devices · Smart TV linked',
                            onTap: () => _info(
                              'Device management UI lands in B1.',
                            ),
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Sign-in activity',
                            subtitle: 'View recent sessions',
                            onTap: () => _info(
                              'Session history reads from the audit log in B1.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      // ─── CONNECTED APPS ───────────────────────────────
                      _Section(
                        label: 'CONNECTED APPS',
                        children: <Widget>[
                          _AppRow(
                            initial: 'T',
                            label: 'Tazkiya',
                            status: 'Linked · Identity + verification',
                            statusGreen: true,
                            onTap: () => _info(
                              'Tazkiya (Phase 2) — placeholder linked state.',
                            ),
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Manage all',
                            onTap: () => _info(
                              'Full ecosystem manager arrives in Phase 2.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      // ─── LANGUAGE & REGION ───────────────────────────
                      _Section(
                        label: 'LANGUAGE & REGION',
                        children: <Widget>[
                          _NavRow(
                            title: 'Language',
                            subtitle: prefs.language.displayLabel,
                            subtitleGold: true,
                            onTap: () =>
                                _openLanguagePicker(context, prefsCtrl, prefs),
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Hijri calendar',
                            subtitle: prefs.hijriCalendar.displayLabel,
                            subtitleGold: true,
                            onTap: () =>
                                _openHijriPicker(context, prefsCtrl, prefs),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      // ─── ABOUT ────────────────────────────────────────
                      _Section(
                        label: 'ABOUT',
                        children: <Widget>[
                          _NavRow(
                            title: 'Smart TV pairing',
                            trailingIcon: Symbols.tv_rounded,
                            onTap: () => context.goNamed(
                              ListenerRoute.nameSmartTvPairing,
                            ),
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Help & Support',
                            trailingIcon: Symbols.help_center_rounded,
                            onTap: () => _info(
                              'Help center deep-links to the Mawaqit docs site (F4 polish).',
                            ),
                          ),
                          const _Divider(),
                          _NavRow(
                            title: 'Privacy & data',
                            trailingIcon: Symbols.security_rounded,
                            onTap: () => _info(
                              'Privacy controls (GDPR export / delete) live in B1.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _SignOutButton(onTap: _signOut),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Live Athan v1.0',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.inkSubtle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mawaqit Ecosystem · Phase 1',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.inkSubtle.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(CalculationMethod m) => switch (m) {
        CalculationMethod.ummAlQura => 'Umm Al-Qura',
        CalculationMethod.isna => 'ISNA',
        CalculationMethod.mwl => 'Muslim World League',
        CalculationMethod.egyptian => 'Egyptian',
        CalculationMethod.karachi => 'Karachi',
        CalculationMethod.moonsightingCommittee => 'Moonsighting Committee',
      };

  void _openMethodPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      builder: (ctx) => _PickerSheet<CalculationMethod>(
        title: 'Calculation method',
        options: CalculationMethod.values,
        labelFor: _methodLabel,
        selected: _method ?? CalculationMethod.mwl,
        onSelected: (m) {
          Navigator.of(ctx).pop();
          _setMethod(m);
        },
      ),
    );
  }

  void _openLanguagePicker(
    BuildContext context,
    UserPreferencesController ctrl,
    UserPreferences prefs,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      builder: (ctx) => _PickerSheet<AppLanguage>(
        title: 'Language',
        options: AppLanguage.values,
        labelFor: (l) => l.displayLabel,
        selected: prefs.language,
        onSelected: (l) {
          Navigator.of(ctx).pop();
          ctrl.setLanguage(l);
        },
      ),
    );
  }

  void _openHijriPicker(
    BuildContext context,
    UserPreferencesController ctrl,
    UserPreferences prefs,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      builder: (ctx) => _PickerSheet<HijriCalendarVariant>(
        title: 'Hijri calendar',
        options: HijriCalendarVariant.values,
        labelFor: (v) => v.displayLabel,
        selected: prefs.hijriCalendar,
        onSelected: (v) {
          Navigator.of(ctx).pop();
          ctrl.setHijriCalendar(v);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeepNight.withValues(alpha: 0.8),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        16,
        AppSpacing.containerMargin,
        20,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              borderRadius: AppRadii.fullAll,
              child: InkWell(
                onTap: onBack,
                borderRadius: AppRadii.fullAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Symbols.arrow_back_rounded,
                        color: AppColors.inkPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.inkPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Settings',
            style: AppTypography.headlineMd.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section container
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadii.xlAll,
            border: Border.all(color: AppColors.borderLow),
          ),
          child: ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.borderLow);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle row
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: AppSpacing.cardInner,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _PillSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillSwitch extends StatelessWidget {
  const _PillSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primaryContainer
              : AppColors.borderMedium,
          borderRadius: AppRadii.fullAll,
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? AppColors.onPrimary : AppColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation row (chevron, optional trailing icon)
// ─────────────────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.subtitleGold = false,
    this.trailingIcon,
  });
  final String title;
  final String? subtitle;
  final bool subtitleGold;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInner,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.inkPrimary,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySm.copyWith(
                          color: subtitleGold
                              ? AppColors.primary
                              : AppColors.inkMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                trailingIcon ?? Symbols.chevron_right_rounded,
                color: AppColors.inkMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connected app row
// ─────────────────────────────────────────────────────────────────────────────

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.initial,
    required this.label,
    required this.status,
    required this.statusGreen,
    required this.onTap,
  });
  final String initial;
  final String label;
  final String status;
  final bool statusGreen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInner,
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.lgAll,
                  color: AppColors.surfaceInset,
                  border: Border.all(color: AppColors.borderMedium),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: AppTypography.bodySm.copyWith(
                        color: statusGreen
                            ? AppColors.successGreen
                            : AppColors.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Symbols.chevron_right_rounded,
                color: AppColors.inkMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign-out button
// ─────────────────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.liveRedBg,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        splashColor: AppColors.liveRed.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            border: Border.all(color: AppColors.liveRed),
          ),
          alignment: Alignment.center,
          child: Text(
            'Sign out',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.liveRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.labelFor,
    required this.selected,
    required this.onSelected,
  });
  final String title;
  final List<T> options;
  final String Function(T) labelFor;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          12,
          AppSpacing.containerMargin,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.inkMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.headlineMd.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            for (final opt in options)
              _PickerRow(
                label: labelFor(opt),
                isSelected: opt == selected,
                onTap: () => onSelected(opt),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.xlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLg.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.inkPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Symbols.check_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background decorative glows
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundGlows extends StatelessWidget {
  const _BackgroundGlows();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldDeep.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
