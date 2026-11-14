import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/design_repository.dart';

class ExploreState {
  const ExploreState({
    this.searchQuery = '',
    this.filters = const DesignFilters(),
    this.sort = DesignSort.recommended,
  });

  final String searchQuery;
  final DesignFilters filters;
  final DesignSort sort;
}

class ExploreController extends Notifier<ExploreState> {
  @override
  ExploreState build() => const ExploreState();

  void setSearchQuery(String value) {
    state = ExploreState(
      searchQuery: value,
      filters: state.filters,
      sort: state.sort,
    );
  }

  void setFilters(DesignFilters value) {
    state = ExploreState(
      searchQuery: state.searchQuery,
      filters: value,
      sort: state.sort,
    );
  }

  void setSort(DesignSort value) {
    state = ExploreState(
      searchQuery: state.searchQuery,
      filters: state.filters,
      sort: value,
    );
  }

  void clear() {
    state = ExploreState(searchQuery: state.searchQuery);
  }

  void resetAll() {
    state = const ExploreState();
  }
}

final exploreControllerProvider =
    NotifierProvider<ExploreController, ExploreState>(ExploreController.new);
