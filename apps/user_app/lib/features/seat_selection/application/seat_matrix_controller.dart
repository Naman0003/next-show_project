import 'package:core_models/core_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/mock_seat_map_data_source.dart';

part 'seat_matrix_controller.g.dart';

/// Outcome of a [SeatMatrixController.toggleSeat] call, so the UI can show
/// the right feedback (e.g. a "max 6 seats" snackbar) without the controller
/// needing to know about `BuildContext`/`ScaffoldMessenger`.
enum SeatToggleResult { selected, deselected, unavailable, limitReached }

class SeatMatrixState {
  SeatMatrixState({required this.layout, this.selectedSeatIds = const []})
      : allSeats = layout.sections.expand((section) => section.seats).toList(),
        _seatById = {
          for (final section in layout.sections)
            for (final seat in section.seats) seat.id: seat,
        };

  final VenueLayout layout;
  final List<String> selectedSeatIds;

  /// Flattened once per state instance — [layout] is immutable, so this
  /// doesn't need re-flattening on every access.
  final List<Seat> allSeats;
  final Map<String, Seat> _seatById;

  Seat? seatById(String id) => _seatById[id];

  double get totalPrice => selectedSeatIds
      .map(seatById)
      .whereType<Seat>()
      .fold(0.0, (sum, seat) => sum + (seat.price ?? 0));

  SeatMatrixState copyWith(
      {VenueLayout? layout, List<String>? selectedSeatIds}) {
    return SeatMatrixState(
      layout: layout ?? this.layout,
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
    );
  }
}

@riverpod
class SeatMatrixController extends _$SeatMatrixController {
  /// Business rule for Phase 4: a single order can't hold more than this
  /// many seats at once.
  static const maxSeats = 6;

  @override
  SeatMatrixState build() {
    return SeatMatrixState(layout: const MockSeatMapDataSource().getLayout());
  }

  SeatToggleResult toggleSeat(String seatId) {
    final seat = state.seatById(seatId);
    if (seat == null) return SeatToggleResult.unavailable;

    final alreadySelected = state.selectedSeatIds.contains(seatId);

    if (!alreadySelected &&
        (seat.status == SeatStatus.sold || seat.status == SeatStatus.locked)) {
      return SeatToggleResult.unavailable;
    }

    if (!alreadySelected && state.selectedSeatIds.length >= maxSeats) {
      return SeatToggleResult.limitReached;
    }

    // Optimistic update: flip the seat's status locally right away. Phase 5
    // swaps this for a real Supabase seat-hold RPC — on failure it would
    // revert this same state instead of trusting the tap.
    final newStatus =
        alreadySelected ? SeatStatus.available : SeatStatus.selected;
    final newSelectedIds = alreadySelected
        ? (List<String>.from(state.selectedSeatIds)..remove(seatId))
        : [...state.selectedSeatIds, seatId];

    state = state.copyWith(
      layout: _withSeatStatus(seatId, newStatus),
      selectedSeatIds: newSelectedIds,
    );

    return alreadySelected
        ? SeatToggleResult.deselected
        : SeatToggleResult.selected;
  }

  VenueLayout _withSeatStatus(String seatId, SeatStatus status) {
    return state.layout.copyWith(
      sections: state.layout.sections.map((section) {
        return section.copyWith(
          seats: section.seats.map((seat) {
            return seat.id == seatId ? seat.copyWith(status: status) : seat;
          }).toList(),
        );
      }).toList(),
    );
  }
}
