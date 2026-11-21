import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_tab.dart';
import '../../../data/local/favorites_dao.dart';
import '../../../data/models/muggu_design.dart';
import '../../../l10n/generated/app_localizations.dart';

class DesignCard extends ConsumerWidget {
  const DesignCard({
    required this.design,
    required this.languageCode,
    required this.isFavorite,
    required this.originTab,
    super.key,
  });

  final MugguDesign design;
  final String languageCode;
  final bool isFavorite;
  final AppTab originTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        key: ValueKey('design-card-${design.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/design/${design.id}', extra: originTab),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 142,
                  child: Image.asset(
                    design.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        l10n.thumbnailUnavailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.94),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: l10n.learnDesign,
                      onPressed: () => context.push(
                        '/design/${design.id}',
                        extra: originTab,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.94),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: isFavorite
                          ? l10n.favoriteRemove
                          : l10n.favoriteAdd,
                      onPressed: () => _toggleFavorite(context, ref, l10n),
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.nameFor(languageCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    design.descriptionFor(languageCode),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(l10n.pendingReview),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final added = await ref
          .read(favoritesDaoProvider)
          .toggleFavorite(design.id);
      ref.invalidate(favoriteIdsProvider);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? l10n.favoriteAdded : l10n.favoriteRemoved),
        ),
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Muggu Studio',
          context: ErrorDescription('while updating a design favourite'),
        ),
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.favoriteUpdateError)));
    }
  }
}
