import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/feature_placeholder.dart';
import '../../../l10n/generated/app_localizations.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FeaturePlaceholder(
      icon: Icons.draw_rounded,
      title: l10n.createEmptyTitle,
      description: l10n.createEmptyDescription,
    );
  }
}
