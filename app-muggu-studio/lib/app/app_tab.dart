enum AppTab {
  home,
  explore,
  create,
  saved;

  static AppTab fromPath(String path) => switch (path) {
    '/explore' => AppTab.explore,
    '/create' => AppTab.create,
    '/saved' => AppTab.saved,
    _ when path.startsWith('/design/') => AppTab.explore,
    _ => AppTab.home,
  };
}

AppTab appTabFromExtra(Object? extra, String fallbackPath) =>
    extra is AppTab ? extra : AppTab.fromPath(fallbackPath);
