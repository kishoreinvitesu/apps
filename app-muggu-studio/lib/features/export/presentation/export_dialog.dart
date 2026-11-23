import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/design_exporter.dart';
import '../application/share_service.dart';

/// Shows an export & share modal bottom sheet to pick resolution and share the design.
Future<void> showExportShareSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required Future<Uint8List> Function(ExportResolution resolution)
  onExportBytes,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);

  final selectedResolution = await showModalBottomSheet<ExportResolution>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.selectResolution ?? 'Select resolution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              key: const ValueKey('export-resolution-standard'),
              leading: const Icon(Icons.photo_size_select_actual_outlined),
              title: Text(l10n?.resolutionStandard ?? 'Standard (1080 × 1080)'),
              subtitle: const Text('Optimal for messaging & social media'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              onTap: () => Navigator.of(ctx).pop(ExportResolution.standard),
            ),
            const SizedBox(height: 10),
            ListTile(
              key: const ValueKey('export-resolution-high'),
              leading: const Icon(Icons.high_quality_outlined),
              title: Text(
                l10n?.resolutionHigh ?? 'High-resolution (2048 × 2048)',
              ),
              subtitle: const Text('Ultra crisp for printing & archiving'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              onTap: () => Navigator.of(ctx).pop(ExportResolution.high),
            ),
          ],
        ),
      ),
    ),
  );

  if (selectedResolution == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n?.exportingImage ?? 'Exporting image...'),
      duration: const Duration(seconds: 1),
    ),
  );

  try {
    final bytes = await onExportBytes(selectedResolution);
    if (!context.mounted) return;

    final shareService = ref.read(shareServiceProvider);
    final renderBox = context.findRenderObject() as RenderBox?;
    final origin = renderBox != null
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : null;

    await shareService.sharePng(
      pngBytes: bytes,
      filename: title.toLowerCase().replaceAll(' ', '_'),
      title: title,
      sharePositionOrigin: origin,
    );
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
