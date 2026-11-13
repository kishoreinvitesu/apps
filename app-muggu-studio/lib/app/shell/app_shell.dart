import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/localization/locale_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.currentPath, required this.child, super.key});

  static const _paths = ['/', '/explore', '/create', '/saved'];

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = _selectedIndexForPath(currentPath);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: l10n.chooseLanguage,
            icon: const Icon(Icons.translate_rounded),
            onSelected: (locale) {
              _changeLocale(context, ref, locale);
            },
            itemBuilder: (context) => [
              _languageItem(
                const Locale('en'),
                l10n.english,
                currentLocale == const Locale('en'),
              ),
              _languageItem(
                const Locale('te'),
                l10n.telugu,
                currentLocale == const Locale('te'),
              ),
              _languageItem(
                const Locale('ta'),
                l10n.tamil,
                currentLocale == const Locale('ta'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => context.go(_paths[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.explore,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline_rounded),
            selectedIcon: const Icon(Icons.add_circle_rounded),
            label: l10n.create,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border_rounded),
            selectedIcon: const Icon(Icons.bookmark_rounded),
            label: l10n.saved,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<Locale> _languageItem(
    Locale locale,
    String label,
    bool selected,
  ) {
    return PopupMenuItem<Locale>(
      value: locale,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: selected ? const Icon(Icons.check_rounded, size: 18) : null,
          ),
          Text(label),
        ],
      ),
    );
  }

  int _selectedIndexForPath(String path) {
    return switch (path) {
      '/explore' => 1,
      '/create' => 2,
      '/saved' => 3,
      _ => 0,
    };
  }

  Future<void> _changeLocale(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
  ) async {
    try {
      await ref.read(localeProvider.notifier).setLocale(locale);
    } on PlatformException {
      if (!context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.languageSaveError)));
    }
  }
}
