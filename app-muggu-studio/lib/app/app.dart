import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

class MugguStudioApp extends ConsumerStatefulWidget {
  const MugguStudioApp({super.key});

  @override
  ConsumerState<MugguStudioApp> createState() => _MugguStudioAppState();
}

class _MugguStudioAppState extends ConsumerState<MugguStudioApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Muggu Studio',
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: _router,
    );
  }
}
