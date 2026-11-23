import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/preferences/preferences_storage.dart';
import '../../../core/preferences/user_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  // Mutable onboarding state (not persisted until Done/Skip)
  String _languageCode = 'en';
  Set<InterestOption> _interests = {InterestOption.all};
  ExperienceLevel _level = ExperienceLevel.beginner;

  static const int _totalPages = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool skipped = false}) async {
    final prefs = UserPreferences(
      languageCode: _languageCode,
      interests: _interests,
      experienceLevel: _level,
      onboardingComplete: true,
    );
    await ref.read(userPreferencesProvider.notifier).savePrefs(prefs);
    if (mounted) context.go('/');
  }

  void _nextPage() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _prevPage() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _changeLocale(Locale locale) async {
    setState(() => _languageCode = locale.languageCode);
    try {
      await ref.read(localeProvider.notifier).setLocale(locale);
    } on PlatformException {
      // silently ignore — locale is best-effort during onboarding
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: MugguColors.deepMaroon,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          l10n.onboardingSubtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _finish(skipped: true),
                    child: Text(l10n.skip),
                  ),
                ],
              ),
            ),

            // ── Page indicator ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? MugguColors.deepMaroon
                          : MugguColors.deepMaroon.withAlpha(60),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // ── Page content ──────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _LanguagePage(
                    selectedCode: _languageCode,
                    onChanged: _changeLocale,
                  ),
                  _InterestsPage(
                    selected: _interests,
                    onChanged: (s) => setState(() => _interests = s),
                  ),
                  _ExperiencePage(
                    selected: _level,
                    onChanged: (l) => setState(() => _level = l),
                  ),
                ],
              ),
            ),

            // ── Navigation row ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  if (_page > 0)
                    OutlinedButton(onPressed: _prevPage, child: Text(l10n.back))
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  FilledButton(
                    onPressed: _nextPage,
                    child: Text(
                      _page == _totalPages - 1 ? l10n.done : l10n.next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 — Language
// ─────────────────────────────────────────────────────────────────────────────
class _LanguagePage extends ConsumerWidget {
  const _LanguagePage({required this.selectedCode, required this.onChanged});

  final String selectedCode;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (const Locale('en'), l10n.english, '🇬🇧'),
      (const Locale('te'), l10n.telugu, '🪔'),
      (const Locale('ta'), l10n.tamil, '🌺'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: Icons.translate_rounded,
            title: l10n.chooseLanguageTitle,
            subtitle: l10n.chooseLanguageSubtitle,
          ),
          const SizedBox(height: 24),
          ...options.map((opt) {
            final (locale, label, emoji) = opt;
            final selected = locale.languageCode == selectedCode;
            return _SelectionTile(
              emoji: emoji,
              label: label,
              selected: selected,
              onTap: () => onChanged(locale),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — Interests
// ─────────────────────────────────────────────────────────────────────────────
class _InterestsPage extends StatelessWidget {
  const _InterestsPage({required this.selected, required this.onChanged});

  final Set<InterestOption> selected;
  final ValueChanged<Set<InterestOption>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (InterestOption.muggu, l10n.interestMuggu, '🌟'),
      (InterestOption.kolam, l10n.interestKolam, '🌸'),
      (InterestOption.rangoli, l10n.interestRangoli, '🎨'),
      (InterestOption.all, l10n.interestAll, '✨'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: Icons.interests_rounded,
            title: l10n.chooseInterestsTitle,
            subtitle: l10n.chooseInterestsSubtitle,
          ),
          const SizedBox(height: 24),
          ...options.map((opt) {
            final (interest, label, emoji) = opt;
            final isSelected = selected.contains(interest);
            return _SelectionTile(
              emoji: emoji,
              label: label,
              selected: isSelected,
              onTap: () {
                final next = Set<InterestOption>.from(selected);
                if (interest == InterestOption.all) {
                  // Selecting "All" clears specific selections
                  onChanged({InterestOption.all});
                } else {
                  next.remove(InterestOption.all);
                  if (isSelected) {
                    next.remove(interest);
                    if (next.isEmpty) next.add(InterestOption.all);
                  } else {
                    next.add(interest);
                  }
                  onChanged(next);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 3 — Experience
// ─────────────────────────────────────────────────────────────────────────────
class _ExperiencePage extends StatelessWidget {
  const _ExperiencePage({required this.selected, required this.onChanged});

  final ExperienceLevel selected;
  final ValueChanged<ExperienceLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: Icons.school_rounded,
            title: l10n.chooseExperienceTitle,
            subtitle: l10n.chooseExperienceSubtitle,
          ),
          const SizedBox(height: 24),
          _ExperienceTile(
            emoji: '🌱',
            title: l10n.experienceBeginner,
            description: l10n.beginnerDescription,
            selected: selected == ExperienceLevel.beginner,
            onTap: () => onChanged(ExperienceLevel.beginner),
          ),
          const SizedBox(height: 12),
          _ExperienceTile(
            emoji: '🎯',
            title: l10n.experienceExperienced,
            description: l10n.experiencedDescription,
            selected: selected == ExperienceLevel.experienced,
            onTap: () => onChanged(ExperienceLevel.experienced),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: MugguColors.deepMaroon.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: MugguColors.deepMaroon, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: MugguColors.darkBrown,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? MugguColors.deepMaroon.withAlpha(20)
                : colorScheme.surfaceContainerLow,
            border: Border.all(
              color: selected ? MugguColors.deepMaroon : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? MugguColors.deepMaroon
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: MugguColors.deepMaroon,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({
    required this.emoji,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? MugguColors.deepMaroon.withAlpha(20)
              : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: selected ? MugguColors.deepMaroon : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? MugguColors.deepMaroon
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: MugguColors.deepMaroon,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
