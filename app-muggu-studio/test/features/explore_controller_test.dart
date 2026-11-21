import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muggu_studio/data/models/muggu_design.dart';
import 'package:muggu_studio/data/repositories/design_repository.dart';
import 'package:muggu_studio/features/explore/application/explore_controller.dart';

void main() {
  test('clearing search does not clear active filters', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(exploreControllerProvider.notifier);

    controller.setFilters(
      const DesignFilters(
        technique: 'geometric_lines',
        difficulty: DesignDifficulty.easy,
      ),
    );
    controller.setSearchQuery('sample');
    controller.setSearchQuery('');

    final state = container.read(exploreControllerProvider);
    expect(state.searchQuery, isEmpty);
    expect(state.filters.technique, 'geometric_lines');
    expect(state.filters.difficulty, DesignDifficulty.easy);
  });
}
