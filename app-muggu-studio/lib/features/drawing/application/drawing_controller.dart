import 'package:material_ui/material_ui.dart';

import '../../../data/models/design_geometry.dart';
import '../domain/drawn_stroke.dart';
import '../domain/symmetry_transform.dart';

abstract final class DrawingPalette {
  static const deepMaroon = Color(0xFF862B37);
  static const riceFlourWhite = Color(0xFFFFFFFF);
  static const turmericGold = Color(0xFFD8A13B);
  static const leafGreen = Color(0xFF55775D);
  static const charcoalBrown = Color(0xFF3C342E);

  static const defaultColors = [
    deepMaroon,
    riceFlourWhite,
    turmericGold,
    leafGreen,
    charcoalBrown,
  ];

  static const thinWidth = 2.0;
  static const mediumWidth = 4.0;
  static const boldWidth = 6.5;

  static const defaultWidths = [thinWidth, mediumWidth, boldWidth];
}

class DrawingController extends ChangeNotifier {
  DrawingController({
    Color? initialColor,
    double? initialStrokeWidth,
    SymmetryMode? initialSymmetry,
  }) : _selectedColor = initialColor ?? DrawingPalette.deepMaroon,
       _selectedStrokeWidth = initialStrokeWidth ?? DrawingPalette.mediumWidth,
       _selectedSymmetry = initialSymmetry ?? SymmetryMode.none;

  static const maxHistoryDepth = 50;
  static const minPointDistanceSquared = 0.00001; // ~0.003 normalized distance

  Color _selectedColor;
  double _selectedStrokeWidth;
  SymmetryMode _selectedSymmetry;

  final List<DrawnStroke> _strokes = [];
  final List<DesignPoint> _activePoints = [];

  final List<List<DrawnStroke>> _undoStack = [];
  final List<List<DrawnStroke>> _redoStack = [];

  Color get selectedColor => _selectedColor;
  double get selectedStrokeWidth => _selectedStrokeWidth;
  SymmetryMode get selectedSymmetry => _selectedSymmetry;

  List<DrawnStroke> get strokes => List.unmodifiable(_strokes);
  List<DesignPoint> get activePoints => List.unmodifiable(_activePoints);

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isDrawing => _activePoints.isNotEmpty;

  void setColor(Color color) {
    if (_selectedColor == color) return;
    _selectedColor = color;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    if ((_selectedStrokeWidth - width).abs() < 0.01) return;
    _selectedStrokeWidth = width;
    notifyListeners();
  }

  void setSymmetry(SymmetryMode mode) {
    if (_selectedSymmetry == mode) return;
    _selectedSymmetry = mode;
    notifyListeners();
  }

  void startStroke(DesignPoint point) {
    _activePoints.clear();
    _activePoints.add(point);
    notifyListeners();
  }

  void addPoint(DesignPoint point) {
    if (_activePoints.isEmpty) {
      _activePoints.add(point);
      notifyListeners();
      return;
    }
    final last = _activePoints.last;
    final dx = point.x - last.x;
    final dy = point.y - last.y;
    if (dx * dx + dy * dy >= minPointDistanceSquared) {
      _activePoints.add(point);
      notifyListeners();
    }
  }

  void endStroke() {
    if (_activePoints.isEmpty) return;

    final mirroredSequences = SymmetryTransform.apply(
      _activePoints,
      _selectedSymmetry,
    );

    _pushUndoSnapshot();
    _redoStack.clear();

    for (final points in mirroredSequences) {
      _strokes.add(
        DrawnStroke(
          points: points,
          color: _selectedColor,
          strokeWidth: _selectedStrokeWidth,
          symmetryMode: _selectedSymmetry,
        ),
      );
    }

    _activePoints.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(List.of(_strokes));
    _strokes.clear();
    _strokes.addAll(_undoStack.removeLast());
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(List.of(_strokes));
    _strokes.clear();
    _strokes.addAll(_redoStack.removeLast());
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty && _activePoints.isEmpty) return;
    _pushUndoSnapshot();
    _redoStack.clear();
    _strokes.clear();
    _activePoints.clear();
    notifyListeners();
  }

  void _pushUndoSnapshot() {
    if (_undoStack.length >= maxHistoryDepth) {
      _undoStack.removeAt(0);
    }
    _undoStack.add(List.of(_strokes));
  }
}
