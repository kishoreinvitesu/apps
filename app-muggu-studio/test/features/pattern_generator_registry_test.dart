import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/design_geometry.dart';
import 'package:muggu_studio/features/create/application/pattern_generator_registry.dart';

void main() {
  const registry = PatternGeneratorRegistry();

  test('radial-flower recipes generate bounded closed petal paths', () {
    final generated = registry.generate(
      const PatternRecipe(
        generatorId: PatternGeneratorRegistry.radialFlowerId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {'petalCount': 24, 'outerRadius': 0.42, 'petalWidth': 0.14},
      ),
    );

    expect(generated.grid, isNull);
    expect(generated.paths, hasLength(24));
    expect(generated.paths.first.id, 'petal_path_01');
    expect(generated.paths.first.commands.last.type, PathCommandType.close);
    for (final path in generated.paths) {
      expect(path.commands, hasLength(4));
      for (final command in path.commands) {
        for (final coordinate in [
          command.x,
          command.y,
          command.control1X,
          command.control1Y,
          command.control2X,
          command.control2Y,
        ].whereType<double>()) {
          expect(coordinate, inInclusiveRange(0, 1));
        }
      }
    }
  });

  test('dot-grid recipes generate explicit layouts and ring paths', () {
    final generated = registry.generate(
      const PatternRecipe(
        generatorId: PatternGeneratorRegistry.dotGridDiamondsId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {
          'rows': 5,
          'columns': 5,
          'layout': 'diamond',
          'margin': 0.12,
        },
      ),
    );

    expect(generated.grid, isNotNull);
    expect(generated.grid!.layout, 'diamond');
    expect(generated.grid!.dots, hasLength(25));
    expect(generated.paths, hasLength(2));
    expect(generated.paths.map((path) => path.groupId), ['ring_01', 'ring_02']);
    expect(
      generated.paths.every(
        (path) => path.commands.last.type == PathCommandType.close,
      ),
      isTrue,
    );
  });

  test('dot-grid loop recipes generate one bounded closed curve per dot', () {
    final generated = registry.generate(
      const PatternRecipe(
        generatorId: PatternGeneratorRegistry.dotGridLoopsId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {
          'rows': 5,
          'columns': 5,
          'layout': 'staggered',
          'margin': 0.12,
        },
      ),
    );

    expect(generated.grid?.dots, hasLength(25));
    expect(generated.paths, hasLength(25));
    for (final path in generated.paths) {
      expect(path.commands, hasLength(6));
      expect(path.commands.last.type, PathCommandType.close);
      DesignPath.fromJson(path.toJson(), 'generated loop');
    }
    expect(
      () => registry.generate(
        const PatternRecipe(
          generatorId: PatternGeneratorRegistry.dotGridLoopsId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {
            'rows': 3,
            'columns': 3,
            'layout': 'square',
            'margin': 0,
          },
        ),
      ),
      throwsFormatException,
    );
  });

  test('the same recipe always generates the same geometry snapshot', () {
    const recipe = PatternRecipe(
      generatorId: PatternGeneratorRegistry.dotGridLoopsId,
      version: PatternGeneratorRegistry.recipeVersion,
      parameters: {
        'rows': 5,
        'columns': 5,
        'layout': 'staggered',
        'margin': 0.12,
      },
    );
    final first = registry.generate(recipe);
    final second = registry.generate(recipe);

    expect(second.recipe.toJson(), equals(first.recipe.toJson()));
    expect(
      second.grid?.dots.map((dot) => [dot.x, dot.y]).toList(),
      equals(first.grid?.dots.map((dot) => [dot.x, dot.y]).toList()),
    );
    expect(
      second.paths.map((path) => path.toJson()).toList(),
      equals(first.paths.map((path) => path.toJson()).toList()),
    );
  });

  test('parabolic Sikku recipes weave quadratic curves across each row', () {
    final generated = registry.generate(
      const PatternRecipe(
        generatorId: PatternGeneratorRegistry.parabolicSikkuId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {
          'rows': 7,
          'columns': 7,
          'layout': 'square',
          'margin': 0.12,
        },
      ),
    );

    expect(generated.grid?.dots, hasLength(49));
    expect(generated.paths, hasLength(7));
    for (final path in generated.paths) {
      expect(path.commands, hasLength(7));
      expect(
        path.commands.where(
          (command) => command.type == PathCommandType.quadraticTo,
        ),
        hasLength(6),
      );
      DesignPath.fromJson(path.toJson(), 'generated Sikku curve');
    }
  });

  test('Rangoli motif recipes generate bounded curved motif paths', () {
    for (final motif in ['floral_mandala', 'peacock', 'paisley']) {
      final generated = registry.generate(
        PatternRecipe(
          generatorId: PatternGeneratorRegistry.rangoliMotifsId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {'motif': motif},
        ),
      );

      expect(generated.grid, isNull);
      expect(generated.paths, isNotEmpty);
      expect(
        generated.paths.any(
          (path) => path.commands.any(
            (command) => command.type == PathCommandType.cubicTo,
          ),
        ),
        isTrue,
      );
      for (final path in generated.paths) {
        DesignPath.fromJson(path.toJson(), 'generated $motif motif');
      }
    }
  });

  test('rectangular square request resolves to a rectangular grid', () {
    final generated = registry.generate(
      const PatternRecipe(
        generatorId: PatternGeneratorRegistry.dotGridDiamondsId,
        version: PatternGeneratorRegistry.recipeVersion,
        parameters: {
          'rows': 3,
          'columns': 5,
          'layout': 'square',
          'margin': 0.12,
        },
      ),
    );

    expect(generated.grid!.layout, 'rectangular');
    expect(generated.grid!.dots, hasLength(15));
  });

  test('unsupported versions and invalid generator parameters fail loudly', () {
    expect(
      () => registry.generate(
        const PatternRecipe(
          generatorId: PatternGeneratorRegistry.radialFlowerId,
          version: 2,
          parameters: {
            'petalCount': 8,
            'outerRadius': 0.36,
            'petalWidth': 0.095,
          },
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => registry.generate(
        const PatternRecipe(
          generatorId: PatternGeneratorRegistry.radialFlowerId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {
            'petalCount': 2,
            'outerRadius': 0.36,
            'petalWidth': 0.095,
          },
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => registry.generate(
        const PatternRecipe(
          generatorId: PatternGeneratorRegistry.dotGridDiamondsId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {
            'rows': 4,
            'columns': 5,
            'layout': 'square',
            'margin': 0.12,
          },
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => registry.generate(
        const PatternRecipe(
          generatorId: PatternGeneratorRegistry.rangoliMotifsId,
          version: PatternGeneratorRegistry.recipeVersion,
          parameters: {'motif': 'unknown'},
        ),
      ),
      throwsFormatException,
    );
  });
}
