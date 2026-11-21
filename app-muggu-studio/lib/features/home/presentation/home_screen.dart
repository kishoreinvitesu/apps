import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/muggu_design.dart';
import '../../../data/repositories/design_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/daily_design.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final catalog = ref.watch(catalogProvider);
    final List<MugguDesign> designs;
    if (catalog.hasValue) {
      designs = catalog.requireValue;
    } else {
      designs = const [];
    }
    final index = dailyDesignIndex(DateTime.now(), designs.length);
    final dailyDesign = index == null ? null : designs[index];
    final statusMessage = catalog.hasError
        ? l10n.catalogLoadError
        : catalog.isLoading
        ? null
        : designs.isEmpty
        ? l10n.exploreEmptyDescription
        : null;

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
                  description:
                      dailyDesign?.descriptionFor(
                        Localizations.localeOf(context).languageCode,
                      ) ??
                      l10n.dailyMugguDescription,
                  design: dailyDesign,
                  statusMessage: statusMessage,
                  isLoading: catalog.isLoading,
                  learnLabel: l10n.learnThisDesign,
                  retryLabel: l10n.retry,
                  createLabel: l10n.createYourOwn,
                  onLearn: dailyDesign == null
                      ? null
                      : () => context.push('/design/${dailyDesign.id}'),
                  onRetry: catalog.hasError
                      ? () => ref.invalidate(catalogProvider)
                      : null,
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
    required this.retryLabel,
    required this.createLabel,
    required this.design,
    required this.statusMessage,
    required this.isLoading,
    required this.onLearn,
    required this.onRetry,
    required this.onCreate,
  });

  final String title;
  final String description;
  final String learnLabel;
  final String retryLabel;
  final String createLabel;
  final MugguDesign? design;
  final String? statusMessage;
  final bool isLoading;
  final VoidCallback? onLearn;
  final VoidCallback? onRetry;
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
              if (design == null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: MugguColors.warmCream.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              color: MugguColors.warmCream,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.spa_rounded,
                            color: MugguColors.warmCream,
                          ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    design!.thumbnail,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: MugguColors.warmCream,
                          ),
                        ),
                  ),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color: MugguColors.warmCream,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (design != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        design!.nameFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: MugguColors.warmCream,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
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
          if (statusMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              statusMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: MugguColors.warmCream.withValues(alpha: 0.9),
              ),
            ),
          ],
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
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: MugguColors.warmCream,
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(
                  color: MugguColors.warmCream.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
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
