import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

const seatRadius = 14.0;
const _vipBorderColor = Color(0xFFCA8A04);

Color seatFillColor(SeatStatus status) {
  switch (status) {
    case SeatStatus.available:
      return Colors.white;
    case SeatStatus.selected:
      return NSColors.royalBlue;
    case SeatStatus.sold:
      return NSColors.textSecondary;
    case SeatStatus.locked:
      return NSColors.warning;
  }
}

/// Renders every seat in a [VenueLayout] as a coloured dot positioned by its
/// normalized `x`/`y`, plus a "screen" indicator along the top edge. Pure
/// paint — all hit-testing happens in the `GestureDetector` that wraps this.
class SeatMatrixPainter extends CustomPainter {
  SeatMatrixPainter({required this.layout});

  final VenueLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    _paintScreen(canvas, size);

    for (final section in layout.sections) {
      for (final seat in section.seats) {
        _paintSeat(canvas, size, seat);
      }
    }
  }

  void _paintScreen(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * 0.15, 8, size.width * 0.7, 10);
    final paint = Paint()..color = NSColors.textSecondary.withOpacity(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
  }

  void _paintSeat(Canvas canvas, Size size, Seat seat) {
    final center = Offset(seat.x * size.width, seat.y * size.height);
    final fillPaint = Paint()..color = seatFillColor(seat.status);
    canvas.drawCircle(center, seatRadius, fillPaint);

    final borderColor = switch (seat.type) {
      SeatType.vip => _vipBorderColor,
      SeatType.wheelchair => NSColors.skyBlue,
      SeatType.standard => NSColors.border,
    };
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = seat.type == SeatType.standard ? 1.5 : 2.5;
    canvas.drawCircle(center, seatRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SeatMatrixPainter oldDelegate) =>
      oldDelegate.layout != layout;
}
