import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_tab.dart';
import '../../../data/local/favorites_dao.dart';
import '../../../data/models/muggu_design.dart';
import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../explore/presentation/design_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (catalog.hasError || favoriteIds.hasError) {
      return _SavedError(
        message: l10n.catalogLoadError,
        onRetry: () {
          ref.invalidate(catalogProvider);
          ref.invalidate(favoriteIdsProvider);
        },
      );
    }
    if (catalog.isLoading || favoriteIds.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final designsById = {
      for (final design in catalog.requireValue) design.id: design,
    };
    final favorites = [
      for (final id in favoriteIds.requireValue)
        if (designsById[id] case final MugguDesign design) design,
    ];

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_border_rounded, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.savedEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(l10n.savedEmptyDescription, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/explore'),
                icon: const Icon(Icons.explore_outlined),
                label: Text(l10n.exploreDesigns),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.savedFavoritesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: favorites.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 230,
            mainAxisExtent: 310,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => DesignCard(
            design: favorites[index],
            languageCode: Localizations.localeOf(context).languageCode,
            isFavorite: true,
            originTab: AppTab.saved,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.savedCreationsComing),
          ),
        ),
      ],
    );
  }
}

class _SavedError extends StatelessWidget {
  const _SavedError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
