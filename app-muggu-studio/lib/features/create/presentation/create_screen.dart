import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/local/creations_dao.dart';
import '../../../data/models/design_geometry.dart';
import '../../../data/models/dot_grid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../creations/domain/user_creation.dart';
import '../../design/presentation/vector_preview.dart';
import '../../drawing/application/drawing_controller.dart';
import '../../drawing/presentation/drawing_canvas.dart';
import '../../drawing/presentation/drawing_toolbar.dart';
import '../application/pattern_generator_registry.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({this.initialCreation, super.key});

  final UserCreation? initialCreation;

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreatorState {
  const _CreatorState({
    required this.generatorId,
    required this.petalCount,
    required this.outerRadius,
    required this.petalWidth,
    required this.gridSize,
    required this.gridLayout,
  });

  static const initial = _CreatorState(
    generatorId: PatternGeneratorRegistry.radialFlowerId,
    petalCount: 8,
    outerRadius: 0.36,
    petalWidth: 0.095,
    gridSize: 5,
    gridLayout: 'square',
  );

  final String generatorId;
  final int petalCount;
  final double outerRadius;
  final double petalWidth;
  final int gridSize;
  final String gridLayout;

  _CreatorState copyWith({
    String? generatorId,
    int? petalCount,
    double? outerRadius,
    double? petalWidth,
    int? gridSize,
    String? gridLayout,
  }) {
    return _CreatorState(
      generatorId: generatorId ?? this.generatorId,
      petalCount: petalCount ?? this.petalCount,
      outerRadius: outerRadius ?? this.outerRadius,
      petalWidth: petalWidth ?? this.petalWidth,
      gridSize: gridSize ?? this.gridSize,
      gridLayout: gridLayout ?? this.gridLayout,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CreatorState &&
          runtimeType == other.runtimeType &&
          generatorId == other.generatorId &&
          petalCount == other.petalCount &&
          (outerRadius - other.outerRadius).abs() < 0.0001 &&
          (petalWidth - other.petalWidth).abs() < 0.0001 &&
          gridSize == other.gridSize &&
          gridLayout == other.gridLayout;

  @override
  int get hashCode => Object.hash(
    generatorId,
    petalCount,
    outerRadius.toStringAsFixed(3),
    petalWidth.toStringAsFixed(3),
    gridSize,
    gridLayout,
  );
}

class _CreateScreenState extends ConsumerState<CreateScreen>
    with SingleTickerProviderStateMixin {
  static const _registry = PatternGeneratorRegistry();

  _CreatorState _state = _CreatorState.initial;
  final List<_CreatorState> _undoStack = [];
  final List<_CreatorState> _redoStack = [];
  _CreatorState? _dragStartState;

  late final TabController _tabController;
  late final DrawingController _drawingController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _drawingController = DrawingController();

    if (widget.initialCreation != null) {
      final initial = widget.initialCreation!;
      if (initial.type == CreationType.freehand && initial.strokes != null) {
        _tabController.index = 1;
        _drawingController.loadStrokes(initial.strokes!);
      } else if (initial.type == CreationType.template &&
          initial.recipe != null) {
        final p = initial.recipe!.parameters;
        if (initial.recipe!.generatorId ==
            PatternGeneratorRegistry.radialFlowerId) {
          _state = _CreatorState(
            generatorId: PatternGeneratorRegistry.radialFlowerId,
            petalCount: (p['petalCount'] as num?)?.toInt() ?? 8,
            outerRadius: (p['outerRadius'] as num?)?.toDouble() ?? 0.36,
            petalWidth: (p['petalWidth'] as num?)?.toDouble() ?? 0.095,
            gridSize: 5,
            gridLayout: 'square',
          );
        } else {
          _state = _CreatorState(
            generatorId: PatternGeneratorRegistry.dotGridDiamondsId,
            petalCount: 8,
            outerRadius: 0.36,
            petalWidth: 0.095,
            gridSize: (p['rows'] as num?)?.toInt() ?? 5,
            gridLayout: (p['layout'] as String?) ?? 'square',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  GeneratedPattern _generatePattern() {
    if (_state.generatorId == PatternGeneratorRegistry.radialFlowerId) {
      return _registry.generate(
        PatternRecipe(
          generatorId: _state.generatorId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {
            'petalCount': _state.petalCount,
            'outerRadius': _state.outerRadius,
            'petalWidth': _state.petalWidth,
          },
        ),
      );
    }
    return _registry.generate(
      PatternRecipe(
        generatorId: _state.generatorId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {
          'rows': _state.gridSize,
          'columns': _state.gridSize,
          'layout': _state.gridLayout,
          'margin': 0.12,
        },
      ),
    );
  }

  void _applyState(_CreatorState next) {
    if (next == _state) return;
    setState(() {
      _undoStack.add(_state);
      _redoStack.clear();
      _state = next;
    });
  }

  void _onSliderChangeStart() {
    _dragStartState = _state;
  }

  void _onSliderChanged(_CreatorState interim) {
    setState(() {
      _state = interim;
    });
  }

  void _onSliderChangeEnd() {
    if (_dragStartState != null && _dragStartState != _state) {
      setState(() {
        _undoStack.add(_dragStartState!);
        _redoStack.clear();
        _dragStartState = null;
      });
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add(_state);
      _state = _undoStack.removeLast();
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add(_state);
      _state = _redoStack.removeLast();
    });
  }

  void _reset() {
    setState(() {
      if (_state != _CreatorState.initial) {
        _undoStack.add(_state);
        _redoStack.clear();
      }
      _state = _CreatorState.initial;
    });
  }

  Future<void> _showSaveTemplateDialog(
    BuildContext context,
    AppLocalizations? l10n,
    GeneratedPattern pattern,
  ) async {
    final defaultTitle =
        _state.generatorId == PatternGeneratorRegistry.radialFlowerId
            ? (l10n?.radialFlower ?? 'Radial flower')
            : (l10n?.dotGridDiamonds ?? 'Dot-grid diamonds');
    final titleController = TextEditingController(text: defaultTitle);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.saveCreation ?? 'Save creation'),
        content: TextField(
          key: const ValueKey('creation-title-input'),
          controller: titleController,
          decoration: InputDecoration(
            labelText: l10n?.creationTitle ?? 'Creation title',
            hintText: l10n?.creationTitleHint ?? 'e.g. My Morning Muggu',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            key: const ValueKey('creation-save-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final title = titleController.text.trim();
      final finalTitle =
          title.isEmpty ? (l10n?.myCreations ?? 'My Creation') : title;
      final now = DateTime.now().toUtc();
      final creation = UserCreation(
        id:
            widget.initialCreation?.id ??
            'creation_${now.microsecondsSinceEpoch}',
        title: finalTitle,
        createdAt: widget.initialCreation?.createdAt ?? now,
        updatedAt: now,
        type: CreationType.template,
        recipe: PatternRecipe(
          generatorId: _state.generatorId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters:
              _state.generatorId == PatternGeneratorRegistry.radialFlowerId
                  ? {
                    'petalCount': _state.petalCount,
                    'outerRadius': _state.outerRadius,
                    'petalWidth': _state.petalWidth,
                  }
                  : {
                    'rows': _state.gridSize,
                    'columns': _state.gridSize,
                    'layout': _state.gridLayout,
                    'margin': 0.12,
                  },
        ),
        paths: pattern.paths,
        grid: pattern.grid,
      );

      await ref.read(creationsDaoProvider).saveCreation(creation);
      ref.invalidate(creationsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.creationSaved ?? 'Creation saved')),
        );
      }
    }
  }

  Future<void> _showSaveFreehandDialog(
    BuildContext context,
    AppLocalizations? l10n,
    DotGrid freehandGrid,
  ) async {
    if (_drawingController.strokes.isEmpty) return;

    final titleController = TextEditingController(
      text: l10n?.freehandCanvas ?? 'Freehand drawing',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.saveCreation ?? 'Save creation'),
        content: TextField(
          key: const ValueKey('creation-title-input'),
          controller: titleController,
          decoration: InputDecoration(
            labelText: l10n?.creationTitle ?? 'Creation title',
            hintText: l10n?.creationTitleHint ?? 'e.g. My Morning Muggu',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            key: const ValueKey('creation-save-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final title = titleController.text.trim();
      final finalTitle =
          title.isEmpty ? (l10n?.myCreations ?? 'My Creation') : title;
      final now = DateTime.now().toUtc();
      final strokes = _drawingController.strokes;
      final paths = UserCreation.strokesToDesignPaths(strokes);

      final creation = UserCreation(
        id:
            widget.initialCreation?.id ??
            'creation_${now.microsecondsSinceEpoch}',
        title: finalTitle,
        createdAt: widget.initialCreation?.createdAt ?? now,
        updatedAt: now,
        type: CreationType.freehand,
        strokes: strokes,
        paths: paths,
        grid: freehandGrid,
      );

      await ref.read(creationsDaoProvider).saveCreation(creation);
      ref.invalidate(creationsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.creationSaved ?? 'Creation saved')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pattern = _generatePattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n?.templatePattern ?? 'Template pattern'),
            Tab(text: l10n?.freehandCanvas ?? 'Freehand canvas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTemplateTab(theme, l10n, pattern),
              _buildFreehandTab(l10n),
            ],
          ),
        ),
      ],
    );
  }

  // ── Template tab ─────────────────────────────────────────────────────────

  Widget _buildTemplateTab(
    ThemeData theme,
    AppLocalizations? l10n,
    GeneratedPattern pattern,
  ) {
    final title = l10n?.createPatternTitle ?? 'Create a pattern';
    final subtitle =
        l10n?.createPatternSubtitle ??
        'Choose a starting pattern and adjust it with a live vector preview.';
    final patternTypeLabel = l10n?.patternType ?? 'Pattern type';
    final radialFlowerLabel = l10n?.radialFlower ?? 'Radial flower';
    final dotGridDiamondsLabel = l10n?.dotGridDiamonds ?? 'Dot-grid diamonds';
    final resetLabel = l10n?.reset ?? 'Reset';
    final undoLabel = l10n?.undo ?? 'Undo';
    final redoLabel = l10n?.redo ?? 'Redo';
    final saveLabel = l10n?.save ?? 'Save';
    final previewNotice =
        l10n?.creatorPreviewNotice ??
        'This preview is generated from editable pattern parameters. '
            'Saving and export are planned for a later update.';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        Text(patternTypeLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const ValueKey('generator-radial_flower'),
              label: Text(radialFlowerLabel),
              selected:
                  _state.generatorId == PatternGeneratorRegistry.radialFlowerId,
              onSelected: (_) => _applyState(
                _state.copyWith(
                  generatorId: PatternGeneratorRegistry.radialFlowerId,
                ),
              ),
            ),
            ChoiceChip(
              key: const ValueKey('generator-dot_grid_diamonds'),
              label: Text(dotGridDiamondsLabel),
              selected:
                  _state.generatorId ==
                  PatternGeneratorRegistry.dotGridDiamondsId,
              onSelected: (_) => _applyState(
                _state.copyWith(
                  generatorId: PatternGeneratorRegistry.dotGridDiamondsId,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        VectorPreview(
          key: const ValueKey('pattern-preview'),
          paths: pattern.paths,
          grid: pattern.grid,
        ),
        const SizedBox(height: 16),
        if (_state.generatorId == PatternGeneratorRegistry.radialFlowerId)
          _buildRadialControls(theme, l10n)
        else
          _buildGridControls(theme, l10n),
        const SizedBox(height: 16),
        // History and Save Action Bar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('creator-undo'),
                  onPressed: _undoStack.isNotEmpty ? _undo : null,
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(undoLabel),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  key: const ValueKey('creator-redo'),
                  onPressed: _redoStack.isNotEmpty ? _redo : null,
                  icon: const Icon(Icons.redo_rounded),
                  label: Text(redoLabel),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('creator-reset'),
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(resetLabel),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const ValueKey('creator-save'),
                  onPressed: () => _showSaveTemplateDialog(context, l10n, pattern),
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: Text(saveLabel),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(previewNotice),
          ),
        ),
      ],
    );
  }

  // ── Freehand tab ──────────────────────────────────────────────────────────

  Widget _buildFreehandTab(AppLocalizations? l10n) {
    final freehandGrid = DotGrid.rectangular(
      rows: _state.gridSize,
      columns: _state.gridSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DrawingCanvas(
              controller: _drawingController,
              grid: freehandGrid,
            ),
          ),
        ),
        DrawingToolbar(
          controller: _drawingController,
          onSave: () => _showSaveFreehandDialog(context, l10n, freehandGrid),
        ),
      ],
    );
  }

  // ── Radial controls ───────────────────────────────────────────────────────

  Widget _buildRadialControls(ThemeData theme, AppLocalizations? l10n) {
    final petalsLabel = l10n?.petals ?? 'Petals';
    final radiusLabel = l10n?.radius ?? 'Radius';
    final petalWidthLabel = l10n?.petalWidth ?? 'Petal width';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$petalsLabel: ${_state.petalCount}',
              style: theme.textTheme.titleMedium,
            ),
            Slider(
              key: const ValueKey('slider-petal-count'),
              min: 3,
              max: 24,
              divisions: 21,
              value: _state.petalCount.toDouble(),
              label: '${_state.petalCount}',
              semanticFormatterCallback: (val) =>
                  '$petalsLabel: ${val.round()}',
              onChangeStart: (_) => _onSliderChangeStart(),
              onChanged: (value) =>
                  _onSliderChanged(_state.copyWith(petalCount: value.round())),
              onChangeEnd: (_) => _onSliderChangeEnd(),
            ),
            const SizedBox(height: 12),
            Text(
              '$radiusLabel: ${(_state.outerRadius * 100).round()}%',
              style: theme.textTheme.titleMedium,
            ),
            Slider(
              key: const ValueKey('slider-radius'),
              min: 0.15,
              max: 0.42,
              divisions: 27,
              value: _state.outerRadius,
              label: '${(_state.outerRadius * 100).round()}%',
              semanticFormatterCallback: (val) =>
                  '$radiusLabel: ${(val * 100).round()}%',
              onChangeStart: (_) => _onSliderChangeStart(),
              onChanged: (value) => _onSliderChanged(
                _state.copyWith(
                  outerRadius: double.parse(value.toStringAsFixed(3)),
                ),
              ),
              onChangeEnd: (_) => _onSliderChangeEnd(),
            ),
            const SizedBox(height: 12),
            Text(
              '$petalWidthLabel: ${(_state.petalWidth * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium,
            ),
            Slider(
              key: const ValueKey('slider-petal-width'),
              min: 0.03,
              max: 0.14,
              divisions: 22,
              value: _state.petalWidth,
              label: '${(_state.petalWidth * 100).toStringAsFixed(1)}%',
              semanticFormatterCallback: (val) =>
                  '$petalWidthLabel: ${(val * 100).toStringAsFixed(1)}%',
              onChangeStart: (_) => _onSliderChangeStart(),
              onChanged: (value) => _onSliderChanged(
                _state.copyWith(
                  petalWidth: double.parse(value.toStringAsFixed(3)),
                ),
              ),
              onChangeEnd: (_) => _onSliderChangeEnd(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid controls ─────────────────────────────────────────────────────────

  Widget _buildGridControls(ThemeData theme, AppLocalizations? l10n) {
    final gridSizeLabel = l10n?.gridSize ?? 'Grid size';
    final dotLayoutLabel = l10n?.dotLayout ?? 'Dot layout';
    final layoutSquare = l10n?.layoutSquare ?? 'Square';
    final layoutStaggered = l10n?.layoutStaggered ?? 'Staggered';
    final layoutDiamond = l10n?.layoutDiamond ?? 'Diamond';
    final helperText =
        l10n?.dotGridSizeHelper ??
        'Traditional Muggu and Kolam patterns typically use 5×5, 7×7 or 9×9 dot grids.';

    final layoutNames = {
      'square': layoutSquare,
      'staggered': layoutStaggered,
      'diamond': layoutDiamond,
    };

    const standardSizes = [3, 5, 7, 9, 11, 13, 15];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$gridSizeLabel: ${_state.gridSize} × ${_state.gridSize}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final size in standardSizes)
                  ChoiceChip(
                    key: ValueKey('grid-size-$size'),
                    label: Text(
                      size == 5 || size == 7 || size == 9
                          ? '$size × $size ★'
                          : '$size × $size',
                    ),
                    selected: _state.gridSize == size,
                    onSelected: (_) =>
                        _applyState(_state.copyWith(gridSize: size)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              key: const ValueKey('slider-grid-size'),
              min: 3,
              max: 15,
              divisions: 6,
              value: _state.gridSize.toDouble(),
              label: '${_state.gridSize}',
              semanticFormatterCallback: (val) =>
                  '$gridSizeLabel: ${val.round()} × ${val.round()}',
              onChangeStart: (_) => _onSliderChangeStart(),
              onChanged: (value) =>
                  _onSliderChanged(_state.copyWith(gridSize: value.round())),
              onChangeEnd: (_) => _onSliderChangeEnd(),
            ),
            Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(dotLayoutLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in layoutNames.entries)
                  ChoiceChip(
                    key: ValueKey('grid-layout-${entry.key}'),
                    label: Text(entry.value),
                    selected: _state.gridLayout == entry.key,
                    onSelected: (_) =>
                        _applyState(_state.copyWith(gridLayout: entry.key)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
