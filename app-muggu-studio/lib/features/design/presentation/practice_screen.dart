import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../drawing/application/drawing_controller.dart';
import '../../drawing/presentation/drawing_canvas.dart';
import '../../drawing/presentation/drawing_toolbar.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({required this.designId, super.key});

  final String designId;

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late final DrawingController _drawingController;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingController();
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    if (catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.hasError) {
      return Center(child: Text(l10n.catalogLoadError));
    }

    final matches = catalog.requireValue.where((d) => d.id == widget.designId);
    if (matches.isEmpty) {
      return Center(child: Text(l10n.exploreNoResultsTitle));
    }

    final design = matches.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            design.nameFor(languageCode),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),

        // Practice guidance
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.practiceGuideNotice,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Drawing canvas (tracing mode: guide paths shown faintly behind)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DrawingCanvas(
              controller: _drawingController,
              grid: design.grid,
              guideDesignPaths: design.paths,
              tracingMode: true,
            ),
          ),
        ),

        // Toolbar
        DrawingToolbar(controller: _drawingController),
      ],
    );
  }
}
