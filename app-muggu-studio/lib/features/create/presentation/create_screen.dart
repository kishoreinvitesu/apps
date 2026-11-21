import 'package:material_ui/material_ui.dart';

import '../../../data/models/design_geometry.dart';
import '../../design/presentation/vector_preview.dart';
import '../application/pattern_generator_registry.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  static const _registry = PatternGeneratorRegistry();
  static const _layouts = {
    'square': 'Square',
    'staggered': 'Staggered',
    'diamond': 'Diamond',
  };

  String _generatorId = PatternGeneratorRegistry.radialFlowerId;
  String _gridLayout = 'square';
  int _petalCount = 8;
  int _gridSize = 5;

  GeneratedPattern _generatePattern() {
    if (_generatorId == PatternGeneratorRegistry.radialFlowerId) {
      return _registry.generate(
        PatternRecipe(
          generatorId: _generatorId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {
            'petalCount': _petalCount,
            'outerRadius': 0.36,
            'petalWidth': 0.095,
          },
        ),
      );
    }
    return _registry.generate(
      PatternRecipe(
        generatorId: _generatorId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {
          'rows': _gridSize,
          'columns': _gridSize,
          'layout': _gridLayout,
          'margin': 0.12,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pattern = _generatePattern();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Create a pattern', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Choose a starting pattern and adjust it with a live vector preview.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Text('Pattern type', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const ValueKey('generator-radial_flower'),
              label: const Text('Radial flower'),
              selected: _generatorId == PatternGeneratorRegistry.radialFlowerId,
              onSelected: (_) => setState(
                () => _generatorId = PatternGeneratorRegistry.radialFlowerId,
              ),
            ),
            ChoiceChip(
              key: const ValueKey('generator-dot_grid_diamonds'),
              label: const Text('Dot-grid diamonds'),
              selected:
                  _generatorId == PatternGeneratorRegistry.dotGridDiamondsId,
              onSelected: (_) => setState(
                () => _generatorId = PatternGeneratorRegistry.dotGridDiamondsId,
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
        const SizedBox(height: 20),
        if (_generatorId == PatternGeneratorRegistry.radialFlowerId)
          _buildPetalControl(theme)
        else
          _buildGridControls(theme),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('creator-reset'),
          onPressed: _reset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Reset'),
        ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.secondaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'This preview is generated from editable pattern parameters. '
              'Saving and export are planned for a later update.',
            ),
          ),
        ),
      ],
    );
  }

  void _reset() {
    setState(() {
      _generatorId = PatternGeneratorRegistry.radialFlowerId;
      _gridLayout = 'square';
      _petalCount = 8;
      _gridSize = 5;
    });
  }

  Widget _buildPetalControl(ThemeData theme) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Petals: $_petalCount', style: theme.textTheme.titleMedium),
          Slider(
            min: 3,
            max: 24,
            divisions: 21,
            value: _petalCount.toDouble(),
            label: '$_petalCount',
            onChanged: (value) => setState(() => _petalCount = value.round()),
          ),
        ],
      ),
    ),
  );

  Widget _buildGridControls(ThemeData theme) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grid size: $_gridSize × $_gridSize',
            style: theme.textTheme.titleMedium,
          ),
          Slider(
            min: 3,
            max: 15,
            divisions: 6,
            value: _gridSize.toDouble(),
            label: '$_gridSize',
            onChanged: (value) => setState(() => _gridSize = value.round()),
          ),
          const SizedBox(height: 8),
          Text('Dot layout', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _layouts.entries)
                ChoiceChip(
                  key: ValueKey('grid-layout-${entry.key}'),
                  label: Text(entry.value),
                  selected: _gridLayout == entry.key,
                  onSelected: (_) => setState(() => _gridLayout = entry.key),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
