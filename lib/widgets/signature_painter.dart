import 'dart:ui';

import 'package:flutter/material.dart';

class SignaturePainter extends CustomPainter {
  final List<Offset?> offsets;

  SignaturePainter({required this.offsets});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final nextIndex = i + 1;

      if (offset != null && nextIndex <= (offsets.length - 1)) {
        final nextOffset = offsets[nextIndex];
        if (nextOffset != null) {
          canvas.drawLine(
            offset,
            nextOffset,
            Paint()..color = Colors.black,
          );
        }
      } else if (offset != null) {
        canvas.drawPoints(
          PointMode.lines,
          [offset],
          Paint()..color = Colors.black,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
