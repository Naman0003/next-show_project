import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../application/seat_matrix_controller.dart';
import 'seat_matrix_painter.dart';

/// Phase 4 scaffold: fully mocked seat matrix, reachable only via the
/// `/debug/seat-matrix` route. Not linked from the live booking flow —
/// Phase 5 wires seat holds to Supabase and hangs this off a real showtime.
class SeatMatrixScreen extends ConsumerWidget {
  const SeatMatrixScreen({super.key});

  void _handleTap(WidgetRef ref, BuildContext context, Offset localPosition) {
    final matrixState = ref.read(seatMatrixControllerProvider);
    final layout = matrixState.layout;
    Seat? closest;
    var closestDistance = double.infinity;

    for (final seat in matrixState.allSeats) {
      final seatCenter = Offset(
        seat.x * layout.canvasWidth,
        seat.y * layout.canvasHeight,
      );
      final distance = (seatCenter - localPosition).distance;
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = seat;
      }
    }

    if (closest == null || closestDistance > seatRadius * 1.5) return;

    final result =
        ref.read(seatMatrixControllerProvider.notifier).toggleSeat(closest.id);
    final message = switch (result) {
      SeatToggleResult.limitReached =>
        'You can select up to ${SeatMatrixController.maxSeats} seats.',
      SeatToggleResult.unavailable => '${closest.id} isn\'t available.',
      SeatToggleResult.selected || SeatToggleResult.deselected => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(seatMatrixControllerProvider);
    final layout = state.layout;

    return Scaffold(
      appBar: AppBar(title: Text('Seat Matrix — ${layout.name}')),
      body: Column(
        children: [
          const _Legend(),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3,
              boundaryMargin: const EdgeInsets.all(40),
              child: GestureDetector(
                onTapUp: (details) =>
                    _handleTap(ref, context, details.localPosition),
                child: CustomPaint(
                  size: Size(layout.canvasWidth, layout.canvasHeight),
                  painter: SeatMatrixPainter(layout: layout),
                ),
              ),
            ),
          ),
          _SummaryBar(state: state),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: const [
          _LegendDot(color: Colors.white, label: 'Available'),
          _LegendDot(color: NSColors.royalBlue, label: 'Selected'),
          _LegendDot(color: NSColors.warning, label: 'Locked'),
          _LegendDot(color: NSColors.textSecondary, label: 'Sold'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: NSColors.border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: NSTextStyles.labelSmall),
      ],
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.state});

  final SeatMatrixState state;

  @override
  Widget build(BuildContext context) {
    final hasSelection = state.selectedSeatIds.isNotEmpty;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: NSColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasSelection
                        ? state.selectedSeatIds.join(', ')
                        : 'No seats selected',
                    style: NSTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '€${state.totalPrice.toStringAsFixed(2)}',
                    style: NSTextStyles.titleMedium.copyWith(
                      color: NSColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            NSPrimaryButton(
              label: 'Checkout',
              onPressed: hasSelection
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Checkout hooks up to Supabase seat holds in Phase 5.',
                          ),
                        ),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
