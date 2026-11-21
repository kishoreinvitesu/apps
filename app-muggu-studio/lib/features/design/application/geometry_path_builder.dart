import 'dart:ui' as ui;

import '../../../data/models/design_geometry.dart';

ui.Path buildDesignPath(DesignPath designPath, ui.Size size) {
  final path = ui.Path();
  for (final command in designPath.commands) {
    final x = command.x;
    final y = command.y;
    switch (command.type) {
      case PathCommandType.moveTo:
        path.moveTo(x! * size.width, y! * size.height);
      case PathCommandType.lineTo:
        path.lineTo(x! * size.width, y! * size.height);
      case PathCommandType.quadraticTo:
        path.quadraticBezierTo(
          command.controlX! * size.width,
          command.controlY! * size.height,
          x! * size.width,
          y! * size.height,
        );
      case PathCommandType.cubicTo:
        path.cubicTo(
          command.control1X! * size.width,
          command.control1Y! * size.height,
          command.control2X! * size.width,
          command.control2Y! * size.height,
          x! * size.width,
          y! * size.height,
        );
      case PathCommandType.arcTo:
        final center = ui.Offset(x! * size.width, y! * size.height);
        path.arcTo(
          ui.Rect.fromCenter(
            center: center,
            width: command.radiusX! * 2 * size.width,
            height: command.radiusY! * 2 * size.height,
          ),
          command.startAngle!,
          command.sweepAngle!,
          false,
        );
      case PathCommandType.close:
        path.close();
    }
  }
  return path;
}
