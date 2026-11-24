import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/drawing_controller.dart';
import '../domain/drawn_stroke.dart';

/// Toolbar for the freehand drawing canvas.
///
/// Displays:
/// - Colour palette row (5 culturally named colours)
/// - Stroke width row (Thin / Medium / Bold)
/// - Symmetry chip row (None / Vertical / Horizontal / 4-Way)
/// - Action row: Undo, Redo, Clear
class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({
    required this.controller,
    this.onSave,
    this.onShare,
    this.compact = false,
    super.key,
  });

  final DrawingController controller;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _ToolbarContent(
        controller: controller,
        onSave: onSave,
        onShare: onShare,
        compact: compact,
      ),
    );
  }
}

class _ToolbarContent extends StatelessWidget {
  const _ToolbarContent({
    required this.controller,
    required this.compact,
    this.onSave,
    this.onShare,
  });

  final DrawingController controller;
  final bool compact;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colour palette
          _SectionLabel(l10n.penColor),
          SizedBox(height: compact ? 4 : 6),
          _ColorPalette(controller: controller),
          SizedBox(height: compact ? 6 : 10),

          // Stroke width
          _SectionLabel(l10n.strokeWidth),
          SizedBox(height: compact ? 4 : 6),
          _StrokeWidthRow(controller: controller, l10n: l10n, compact: compact),
          SizedBox(height: compact ? 6 : 10),

          // Symmetry
          _SectionLabel(l10n.symmetry),
          SizedBox(height: compact ? 4 : 6),
          _SymmetryRow(controller: controller, l10n: l10n, compact: compact),
          SizedBox(height: compact ? 6 : 10),

          // Actions
          _ActionRow(
            controller: controller,
            l10n: l10n,
            context: context,
            onSave: onSave,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Color palette
// ---------------------------------------------------------------------------

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({required this.controller});

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final color in DrawingPalette.defaultColors)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _ColorSwatch(
              color: color,
              selected: controller.selectedColor == color,
              onTap: () => controller.setColor(color),
            ),
          ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  static const _size = 32.0;
  static const _borderWidth = 2.5;

  @override
  Widget build(BuildContext context) {
    final ringColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: selected
              ? Border.all(color: ringColor, width: _borderWidth)
              : Border.all(
                  color: Theme.of(context).colorScheme.outline
                      .withValues(alpha: 0.4),
                  width: 1,
                ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: ringColor.withValues(alpha: 0.35),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stroke width
// ---------------------------------------------------------------------------

class _StrokeWidthRow extends StatelessWidget {
  const _StrokeWidthRow({
    required this.controller,
    required this.l10n,
    required this.compact,
  });

  final DrawingController controller;
  final AppLocalizations l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final widthLabels = [l10n.thin, l10n.medium, l10n.bold];
    final widths = DrawingPalette.defaultWidths;

    return Row(
      children: [
        for (var i = 0; i < widths.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _WidthButton(
              label: widthLabels[i],
              strokeWidth: widths[i],
              selected:
                  (controller.selectedStrokeWidth - widths[i]).abs() < 0.01,
              onTap: () => controller.setStrokeWidth(widths[i]),
              compact: compact,
            ),
          ),
      ],
    );
  }
}

class _WidthButton extends StatelessWidget {
  const _WidthButton({
    required this.label,
    required this.strokeWidth,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final double strokeWidth;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: compact ? 20 : 24,
              child: Center(
                child: Container(
                  height: strokeWidth.clamp(1.5, 7.0),
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Symmetry
// ---------------------------------------------------------------------------

class _SymmetryRow extends StatelessWidget {
  const _SymmetryRow({
    required this.controller,
    required this.l10n,
    required this.compact,
  });

  final DrawingController controller;
  final AppLocalizations l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final modes = SymmetryMode.values;
    final labels = [
      l10n.symmetryNone,
      l10n.symmetryVertical,
      l10n.symmetryHorizontal,
      l10n.symmetryFourWay,
    ];

    final chips = [
      for (var i = 0; i < modes.length; i++)
        ChoiceChip(
          label: Text(labels[i]),
          selected: controller.selectedSymmetry == modes[i],
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          labelPadding: compact
              ? const EdgeInsets.symmetric(horizontal: 6)
              : null,
          onSelected: (_) => controller.setSymmetry(modes[i]),
        ),
    ];

    if (compact) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < chips.length; i++)
              Padding(
                padding: EdgeInsets.only(right: i == chips.length - 1 ? 0 : 8),
                child: chips[i],
              ),
          ],
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 4, children: chips);
  }
}

// ---------------------------------------------------------------------------
// Action row
// ---------------------------------------------------------------------------

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.controller,
    required this.l10n,
    required this.context,
    this.onSave,
    this.onShare,
  });

  final DrawingController controller;
  final AppLocalizations l10n;
  final BuildContext context;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearCanvas),
        content: Text(l10n.clearCanvasConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.clearCanvas),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          tooltip: 'Undo',
          icon: const Icon(Icons.undo_rounded),
          onPressed: controller.canUndo ? controller.undo : null,
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: 'Redo',
          icon: const Icon(Icons.redo_rounded),
          onPressed: controller.canRedo ? controller.redo : null,
        ),
        const Spacer(),
        IconButton.outlined(
          tooltip: l10n.clearCanvas,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: controller.strokes.isEmpty ? null : _confirmClear,
        ),
        if (onShare != null) ...[
          const SizedBox(width: 8),
          IconButton.outlined(
            key: const ValueKey('drawing-share'),
            tooltip: l10n.shareDesign,
            icon: const Icon(Icons.share_rounded),
            onPressed: controller.strokes.isEmpty ? null : onShare,
          ),
        ],
        if (onSave != null) ...[
          const SizedBox(width: 8),
          IconButton.filled(
            key: const ValueKey('drawing-save'),
            tooltip: l10n.saveCreation,
            icon: const Icon(Icons.bookmark_add_rounded),
            onPressed: controller.strokes.isEmpty ? null : onSave,
          ),
        ],
      ],
    );
  }
}
