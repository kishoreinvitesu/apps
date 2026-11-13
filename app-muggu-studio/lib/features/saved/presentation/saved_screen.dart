import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/generated/app_localizations.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FeaturePlaceholder(
      icon: Icons.bookmark_border_rounded,
      title: l10n.savedEmptyTitle,
      description: l10n.savedEmptyDescription,
    );
  }
}
