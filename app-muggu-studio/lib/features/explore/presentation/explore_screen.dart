import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/generated/app_localizations.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FeaturePlaceholder(
      icon: Icons.grid_view_rounded,
      title: l10n.exploreEmptyTitle,
      description: l10n.exploreEmptyDescription,
    );
  }
}
