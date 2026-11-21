import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'vector_preview.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({required this.designId, super.key});

  final String designId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    if (catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.hasError) {
      return Center(child: Text(l10n.catalogLoadError));
    }
    final matches = catalog.requireValue.where(
      (design) => design.id == designId,
    );
    if (matches.isEmpty) {
      return Center(child: Text(l10n.exploreNoResultsTitle));
    }

    final design = matches.first;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          design.nameFor(languageCode),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        VectorPreview(design: design),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.practiceComingSoon,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.practiceComingSoonDescription),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
