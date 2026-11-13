import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.brandLine,
                  style: textTheme.titleMedium?.copyWith(
                    color: MugguColors.leafGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.journeyTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    color: MugguColors.darkBrown,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.journeyDescription,
                  style: textTheme.bodyLarge?.copyWith(
                    color: MugguColors.darkBrown.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _DailyMugguCard(
                  title: l10n.dailyMuggu,
                  description: l10n.dailyMugguDescription,
                  learnLabel: l10n.learnThisDesign,
                  createLabel: l10n.createYourOwn,
                  onLearn: () => context.go('/explore'),
                  onCreate: () => context.go('/create'),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.chooseYourPath,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _JourneyCard(
                  icon: Icons.grid_view_rounded,
                  title: l10n.exploreDesigns,
                  description: l10n.exploreDesignsDescription,
                  onTap: () => context.go('/explore'),
                ),
                const SizedBox(height: 12),
                _JourneyCard(
                  icon: Icons.draw_rounded,
                  title: l10n.openCreator,
                  description: l10n.openCreatorDescription,
                  onTap: () => context.go('/create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyMugguCard extends StatelessWidget {
  const _DailyMugguCard({
    required this.title,
    required this.description,
    required this.learnLabel,
    required this.createLabel,
    required this.onLearn,
    required this.onCreate,
  });

  final String title;
  final String description;
  final String learnLabel;
  final String createLabel;
  final VoidCallback onLearn;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: MugguColors.deepMaroon,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: MugguColors.warmCream.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.spa_rounded, color: MugguColors.warmCream),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: MugguColors.warmCream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: MugguColors.warmCream.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onLearn,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(learnLabel),
            style: FilledButton.styleFrom(
              backgroundColor: MugguColors.warmCream,
              foregroundColor: MugguColors.deepMaroon,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.draw_rounded),
            label: Text(createLabel),
            style: TextButton.styleFrom(
              foregroundColor: MugguColors.warmCream,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, color: colors.primary, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward_rounded),
      ),
    );
  }
}
