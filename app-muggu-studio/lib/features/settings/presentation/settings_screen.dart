import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_version.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/preferences/preferences_storage.dart';
import '../../../core/preferences/user_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefsAsync = ref.watch(userPreferencesProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.back,
          onPressed: () => context.pop(),
        ),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prefs) => ListView(
          children: [
            // ── Language ───────────────────────────────────────────────────
            _SectionHeader(label: l10n.chooseLanguage),
            _LanguageTile(
              locale: const Locale('en'),
              label: l10n.english,
              emoji: '🇬🇧',
              selected: currentLocale.languageCode == 'en',
              onTap: () =>
                  _changeLocale(context, ref, const Locale('en'), l10n),
            ),
            _LanguageTile(
              locale: const Locale('te'),
              label: l10n.telugu,
              emoji: '🪔',
              selected: currentLocale.languageCode == 'te',
              onTap: () =>
                  _changeLocale(context, ref, const Locale('te'), l10n),
            ),
            _LanguageTile(
              locale: const Locale('ta'),
              label: l10n.tamil,
              emoji: '🌺',
              selected: currentLocale.languageCode == 'ta',
              onTap: () =>
                  _changeLocale(context, ref, const Locale('ta'), l10n),
            ),

            // ── Preferences ────────────────────────────────────────────────
            _SectionHeader(label: l10n.preferencesSection),
            _InterestsTile(prefs: prefs, ref: ref),
            _ExperienceTile(prefs: prefs, ref: ref),

            // ── About ──────────────────────────────────────────────────────
            _SectionHeader(label: l10n.aboutSection),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l10n.appVersion),
              trailing: Chip(
                label: Text(
                  AppVersion.display,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                backgroundColor: MugguColors.deepMaroon.withAlpha(20),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wifi_off_rounded),
              title: Text(l10n.offlineReady),
            ),

            // ── Data ───────────────────────────────────────────────────────
            _SectionHeader(label: l10n.dataSection),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.clearLocalData,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _confirmClearData(context, ref, l10n),
            ),

            // ── Privacy ────────────────────────────────────────────────────
            _SectionHeader(label: l10n.privacySection),
            ListTile(
              leading: const Icon(Icons.policy_outlined),
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              onTap: () {
                // Placeholder — no browser launch in offline-first MVP
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy — coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLocale(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    AppLocalizations l10n,
  ) async {
    try {
      await ref.read(localeProvider.notifier).setLocale(locale);
      // Also persist to user prefs
      final current = ref.read(userPreferencesProvider).asData?.value;
      if (current != null) {
        await ref
            .read(userPreferencesProvider.notifier)
            .savePrefs(current.copyWith(languageCode: locale.languageCode));
      }
    } on PlatformException {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.languageSaveError)));
      }
    }
  }

  Future<void> _confirmClearData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearLocalDataConfirm),
        content: Text(l10n.clearLocalDataDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clearLocalData),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(userPreferencesProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.dataCleared)));
        // Restart onboarding
        context.go('/onboarding');
      }
    }
  }
}

// ── InterestsTile ─────────────────────────────────────────────────────────────
class _InterestsTile extends ConsumerWidget {
  const _InterestsTile({required this.prefs, required this.ref});

  final UserPreferences prefs;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (InterestOption.muggu, l10n.interestMuggu),
      (InterestOption.kolam, l10n.interestKolam),
      (InterestOption.rangoli, l10n.interestRangoli),
      (InterestOption.all, l10n.interestAll),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseInterestsTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: options.map((opt) {
              final (interest, label) = opt;
              final selected = prefs.interests.contains(interest);
              return FilterChip(
                label: Text(label),
                selected: selected,
                selectedColor: MugguColors.deepMaroon.withAlpha(30),
                checkmarkColor: MugguColors.deepMaroon,
                onSelected: (_) async {
                  final next = Set<InterestOption>.from(prefs.interests);
                  if (interest == InterestOption.all) {
                    await ref
                        .read(userPreferencesProvider.notifier)
                        .savePrefs(
                          prefs.copyWith(interests: {InterestOption.all}),
                        );
                  } else {
                    next.remove(InterestOption.all);
                    if (selected) {
                      next.remove(interest);
                      if (next.isEmpty) next.add(InterestOption.all);
                    } else {
                      next.add(interest);
                    }
                    await ref
                        .read(userPreferencesProvider.notifier)
                        .savePrefs(prefs.copyWith(interests: next));
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── ExperienceTile ────────────────────────────────────────────────────────────
class _ExperienceTile extends ConsumerWidget {
  const _ExperienceTile({required this.prefs, required this.ref});

  final UserPreferences prefs;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseExperienceTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ExperienceLevel>(
            segments: [
              ButtonSegment(
                value: ExperienceLevel.beginner,
                label: Text(l10n.experienceBeginner),
                icon: const Icon(Icons.eco_rounded),
              ),
              ButtonSegment(
                value: ExperienceLevel.experienced,
                label: Text(l10n.experienceExperienced),
                icon: const Icon(Icons.star_rounded),
              ),
            ],
            selected: {prefs.experienceLevel},
            onSelectionChanged: (s) async {
              await ref
                  .read(userPreferencesProvider.notifier)
                  .savePrefs(prefs.copyWith(experienceLevel: s.first));
            },
          ),
        ],
      ),
    );
  }
}

// ── SectionHeader ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: MugguColors.deepMaroon,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ── LanguageTile ──────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final Locale locale;
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_rounded, color: MugguColors.deepMaroon)
          : null,
      onTap: onTap,
      selected: selected,
      selectedColor: MugguColors.deepMaroon,
    );
  }
}
