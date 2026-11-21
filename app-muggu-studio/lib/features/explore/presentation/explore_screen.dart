import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_tab.dart';
import '../../../data/local/favorites_dao.dart';
import '../../../data/models/dot_grid.dart';
import '../../../data/models/muggu_design.dart';
import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/explore_controller.dart';
import 'design_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(exploreControllerProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(exploreControllerProvider.notifier).setSearchQuery('');
  }

  void _resetSearchAndFilters() {
    _searchController.clear();
    ref.read(exploreControllerProvider.notifier).resetAll();
  }

  void _syncSearchText(String query) {
    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final catalog = ref.watch(catalogProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (catalog.hasError || favoriteIds.hasError) {
      return _LoadError(
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

    final designs = catalog.requireValue;
    final favorites = favoriteIds.requireValue.toSet();
    final state = ref.watch(exploreControllerProvider);
    _syncSearchText(state.searchQuery);
    final results = DesignRepository.query(
      designs: designs,
      searchQuery: state.searchQuery,
      filters: state.filters,
      sort: state.sort,
      languageCode: Localizations.localeOf(context).languageCode,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.sampleContentNotice)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: ref
              .read(exploreControllerProvider.notifier)
              .setSearchQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.exploreSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            border: const OutlineInputBorder(),
            suffixIcon: state.searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clear,
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  _showFilters(context, ref, designs, state.filters),
              icon: const Icon(Icons.tune_rounded),
              label: Text('${l10n.filters} (${state.filters.activeCount})'),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<DesignSort>(
              tooltip: l10n.sort,
              initialValue: state.sort,
              onSelected: ref.read(exploreControllerProvider.notifier).setSort,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: DesignSort.recommended,
                  child: Text(l10n.sortRecommended),
                ),
                PopupMenuItem(
                  value: DesignSort.name,
                  child: Text(l10n.sortName),
                ),
                PopupMenuItem(
                  value: DesignSort.difficulty,
                  child: Text(l10n.difficulty),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort_rounded),
                    const SizedBox(width: 8),
                    Text(_sortLabel(l10n, state.sort)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (!state.filters.isEmpty)
              TextButton(
                onPressed: ref.read(exploreControllerProvider.notifier).clear,
                child: Text(l10n.clear),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          _NoResults(
            title: l10n.exploreNoResultsTitle,
            description: l10n.exploreNoResultsDescription,
            onClear: _resetSearchAndFilters,
            clearLabel: l10n.clear,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 230,
              mainAxisExtent: 310,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) => DesignCard(
              design: results[index],
              languageCode: Localizations.localeOf(context).languageCode,
              isFavorite: favorites.contains(results[index].id),
              originTab: AppTab.explore,
            ),
          ),
      ],
    );
  }

  String _sortLabel(AppLocalizations l10n, DesignSort sort) {
    return switch (sort) {
      DesignSort.recommended => l10n.sortRecommended,
      DesignSort.name => l10n.sortName,
      DesignSort.difficulty => l10n.difficulty,
    };
  }

  Future<void> _showFilters(
    BuildContext context,
    WidgetRef ref,
    List<MugguDesign> designs,
    DesignFilters initialFilters,
  ) async {
    var filters = initialFilters;
    final l10n = AppLocalizations.of(context)!;
    final regions = _sortedValues(designs.map((design) => design.region));
    final traditions = _sortedValues(designs.map((design) => design.tradition));
    final techniques = _sortedValues(designs.map((design) => design.technique));
    final difficulties = designs.map((design) => design.difficulty).toSet();
    final grids =
        designs
            .map((design) => design.grid)
            .whereType<DotGrid>()
            .toSet()
            .toList()
          ..sort((left, right) {
            final byRows = left.rows.compareTo(right.rows);
            return byRows != 0 ? byRows : left.columns.compareTo(right.columns);
          });

    final appliedFilters = await showModalBottomSheet<DesignFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void update(DesignFilters next) {
            setSheetState(() => filters = next);
          }

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.filters,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _FilterSection(
                      title: l10n.region,
                      emptyMessage: l10n.noReviewedCategories,
                      values: regions,
                      selectedValue: filters.region,
                      labelForValue: (value) => value,
                      onSelected: (value) => update(
                        DesignFilters(
                          region: filters.region == value ? null : value,
                          tradition: filters.tradition,
                          technique: filters.technique,
                          difficulty: filters.difficulty,
                          grid: filters.grid,
                        ),
                      ),
                    ),
                    _FilterSection(
                      title: l10n.tradition,
                      emptyMessage: l10n.noReviewedCategories,
                      values: traditions,
                      selectedValue: filters.tradition,
                      labelForValue: (value) => value,
                      onSelected: (value) => update(
                        DesignFilters(
                          region: filters.region,
                          tradition: filters.tradition == value ? null : value,
                          technique: filters.technique,
                          difficulty: filters.difficulty,
                          grid: filters.grid,
                        ),
                      ),
                    ),
                    _FilterSection(
                      title: l10n.technique,
                      emptyMessage: l10n.noReviewedCategories,
                      values: techniques,
                      selectedValue: filters.technique,
                      labelForValue: (value) => value == 'geometric_lines'
                          ? l10n.techniqueGeometricLines
                          : value,
                      onSelected: (value) => update(
                        DesignFilters(
                          region: filters.region,
                          tradition: filters.tradition,
                          technique: filters.technique == value ? null : value,
                          difficulty: filters.difficulty,
                          grid: filters.grid,
                        ),
                      ),
                    ),
                    _FilterSection<DesignDifficulty>(
                      title: l10n.difficulty,
                      emptyMessage: l10n.noReviewedCategories,
                      values: [
                        for (final difficulty in DesignDifficulty.values)
                          if (difficulties.contains(difficulty)) difficulty,
                      ],
                      selectedValue: filters.difficulty,
                      labelForValue: (value) => _difficultyLabel(l10n, value),
                      onSelected: (value) => update(
                        DesignFilters(
                          region: filters.region,
                          tradition: filters.tradition,
                          technique: filters.technique,
                          difficulty: filters.difficulty == value
                              ? null
                              : value,
                          grid: filters.grid,
                        ),
                      ),
                    ),
                    _FilterSection<DotGrid>(
                      title: l10n.dotGrid,
                      emptyMessage: l10n.noDotGridCategories,
                      values: grids,
                      selectedValue: filters.grid,
                      labelForValue: (value) =>
                          '${value.rows} × ${value.columns}',
                      onSelected: (value) => update(
                        DesignFilters(
                          region: filters.region,
                          tradition: filters.tradition,
                          technique: filters.technique,
                          difficulty: filters.difficulty,
                          grid: filters.grid == value ? null : value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => update(const DesignFilters()),
                          child: Text(l10n.clear),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, filters),
                          child: Text(l10n.apply),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (appliedFilters != null) {
      ref.read(exploreControllerProvider.notifier).setFilters(appliedFilters);
    }
  }

  List<String> _sortedValues(Iterable<String?> values) =>
      (values.whereType<String>().toSet().toList()..sort());

  String _difficultyLabel(AppLocalizations l10n, DesignDifficulty difficulty) {
    return switch (difficulty) {
      DesignDifficulty.easy => l10n.easy,
      DesignDifficulty.intermediate => l10n.intermediate,
      DesignDifficulty.advanced => l10n.advanced,
    };
  }
}

class _FilterSection<T> extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.emptyMessage,
    required this.values,
    required this.selectedValue,
    required this.labelForValue,
    required this.onSelected,
  });

  final String title;
  final String emptyMessage;
  final List<T> values;
  final T? selectedValue;
  final String Function(T value) labelForValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (values.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            Wrap(
              spacing: 8,
              children: [
                for (final value in values)
                  FilterChip(
                    label: Text(labelForValue(value)),
                    selected: value == selectedValue,
                    onSelected: (_) => onSelected(value),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

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

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.title,
    required this.description,
    required this.onClear,
    required this.clearLabel,
  });

  final String title;
  final String description;
  final VoidCallback onClear;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 40),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(description, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: Text(clearLabel)),
        ],
      ),
    );
  }
}
