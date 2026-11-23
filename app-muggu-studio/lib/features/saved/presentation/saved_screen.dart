import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_tab.dart';
import '../../../data/local/creations_dao.dart';
import '../../../data/local/favorites_dao.dart';
import '../../../data/models/muggu_design.dart';
import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../creations/domain/user_creation.dart';
import '../../design/presentation/vector_preview.dart';
import '../../export/application/design_exporter.dart';
import '../../export/presentation/export_dialog.dart';
import '../../explore/presentation/design_card.dart';

enum SavedSection { favorites, creations }

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  SavedSection _selectedSection = SavedSection.favorites;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SegmentedButton<SavedSection>(
            segments: [
              ButtonSegment<SavedSection>(
                value: SavedSection.favorites,
                icon: const Icon(Icons.bookmark_rounded),
                label: Text(l10n.savedFavoritesTitle),
              ),
              ButtonSegment<SavedSection>(
                value: SavedSection.creations,
                icon: const Icon(Icons.brush_rounded),
                label: Text(l10n.myCreations),
              ),
            ],
            selected: {_selectedSection},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedSection = newSelection.first;
              });
            },
          ),
        ),
        Expanded(
          child: switch (_selectedSection) {
            SavedSection.favorites => _FavoritesView(l10n: l10n),
            SavedSection.creations => _CreationsView(l10n: l10n),
          },
        ),
      ],
    );
  }
}

class _FavoritesView extends ConsumerWidget {
  const _FavoritesView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);

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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
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
    );
  }
}

class _CreationsView extends ConsumerWidget {
  const _CreationsView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationsAsync = ref.watch(creationsListProvider);

    return creationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _SavedError(
        message: error.toString(),
        onRetry: () => ref.invalidate(creationsListProvider),
      ),
      data: (creations) {
        if (creations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.brush_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noCreationsYet,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noCreationsDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/create'),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.create),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: creations.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 230,
            mainAxisExtent: 290,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) =>
              _CreationCard(creation: creations[index], l10n: l10n),
        );
      },
    );
  }
}

class _CreationCard extends ConsumerWidget {
  const _CreationCard({required this.creation, required this.l10n});

  final UserCreation creation;
  final AppLocalizations l10n;

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: creation.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameCreation),
        content: TextField(
          key: const ValueKey('creation-rename-input'),
          controller: controller,
          decoration: InputDecoration(labelText: l10n.creationTitle),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('creation-rename-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final newTitle = controller.text.trim();
      if (newTitle.isNotEmpty && newTitle != creation.title) {
        await ref.read(creationsDaoProvider).updateTitle(creation.id, newTitle);
        ref.invalidate(creationsListProvider);
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCreation),
        content: Text(l10n.deleteCreationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('creation-delete-confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteCreation),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(creationsDaoProvider).deleteCreation(creation.id);
      ref.invalidate(creationsListProvider);
    }
  }

  Future<void> _shareCreation(BuildContext context, WidgetRef ref) async {
    final exporter = ref.read(designExporterProvider);
    await showExportShareSheet(
      context: context,
      ref: ref,
      title: creation.title,
      onExportBytes: (resolution) =>
          exporter.exportCreation(creation, resolution: resolution),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typeLabel = creation.type == CreationType.freehand
        ? l10n.freehandCanvas
        : l10n.templatePattern;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: VectorPreview(paths: creation.paths, grid: creation.grid),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        creation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (action) {
                    if (action == 'share') {
                      _shareCreation(context, ref);
                    } else if (action == 'rename') {
                      _showRenameDialog(context, ref);
                    } else if (action == 'delete') {
                      _showDeleteDialog(context, ref);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.shareDesign),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.renameCreation),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.deleteCreation,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
