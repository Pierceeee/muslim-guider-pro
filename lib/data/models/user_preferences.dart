/// Hijri calendar variant choices. The picker on settings cycles through these.
enum HijriCalendarVariant { ummAlQura, civic, fatemid }

extension HijriCalendarVariantX on HijriCalendarVariant {
  String get displayLabel => switch (this) {
        HijriCalendarVariant.ummAlQura => 'Umm Al-Qura',
        HijriCalendarVariant.civic => 'Tabular (Civic)',
        HijriCalendarVariant.fatemid => 'Fatemid (Bohra)',
      };
}

/// App language (initial v1 support). B-phase expands the list.
enum AppLanguage { english, arabic, urdu, malay, indonesian, turkish }

extension AppLanguageX on AppLanguage {
  String get displayLabel => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.arabic => 'العربية',
        AppLanguage.urdu => 'اردو',
        AppLanguage.malay => 'Bahasa Melayu',
        AppLanguage.indonesian => 'Bahasa Indonesia',
        AppLanguage.turkish => 'Türkçe',
      };
}

/// Listener-side preferences edited from the settings screen.
///
/// Calculation method intentionally lives in `ScheduleRepository` (not here)
/// because it affects `todaysPrayerScheduleProvider` directly — keeping the
/// two in sync via a single source of truth.
class UserPreferences {
  const UserPreferences({
    this.autoPlayNearestAthan = true,
    this.backgroundProximity = true,
    this.prayerReminders = false,
    this.faceId = true,
    this.language = AppLanguage.english,
    this.hijriCalendar = HijriCalendarVariant.ummAlQura,
  });

  final bool autoPlayNearestAthan;
  final bool backgroundProximity;
  final bool prayerReminders;
  final bool faceId;
  final AppLanguage language;
  final HijriCalendarVariant hijriCalendar;

  UserPreferences copyWith({
    bool? autoPlayNearestAthan,
    bool? backgroundProximity,
    bool? prayerReminders,
    bool? faceId,
    AppLanguage? language,
    HijriCalendarVariant? hijriCalendar,
  }) {
    return UserPreferences(
      autoPlayNearestAthan:
          autoPlayNearestAthan ?? this.autoPlayNearestAthan,
      backgroundProximity: backgroundProximity ?? this.backgroundProximity,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      faceId: faceId ?? this.faceId,
      language: language ?? this.language,
      hijriCalendar: hijriCalendar ?? this.hijriCalendar,
    );
  }
}
