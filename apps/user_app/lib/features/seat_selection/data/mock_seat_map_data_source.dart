import 'package:core_models/core_models.dart';

/// Stands in for the Phase 5 Supabase RPC that will return a venue's real
/// seat map. Builds a raw JSON payload (matching [VenueLayout]'s wire
/// format) for a generic 10x10 single-screen cinema, then parses it through
/// `fromJson` — so the parsing path is exercised exactly like it will be
/// against a live payload later.
class MockSeatMapDataSource {
  const MockSeatMapDataSource();

  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  static const _seatsPerRow = 10;
  static const _vipRows = {'E', 'F'};
  static const _wheelchairSeats = {'J1', 'J10'};
  static const _preSoldSeats = {'C4', 'G7', 'B8'};
  static const _preLockedSeats = {'D6'};

  VenueLayout getLayout() => VenueLayout.fromJson(_buildPayload());

  Map<String, dynamic> _buildPayload() {
    final vipSeats = <Map<String, dynamic>>[];
    final standardSeats = <Map<String, dynamic>>[];

    for (var r = 0; r < _rows.length; r++) {
      final row = _rows[r];
      final isVipRow = _vipRows.contains(row);

      for (var n = 1; n <= _seatsPerRow; n++) {
        final seatId = '$row$n';
        // Leave a centre-aisle gap between seats 5 and 6.
        final col = n <= 5 ? n - 1 : n;
        final x = (col + 0.5) / (_seatsPerRow + 1);
        final y = (r + 0.5) / _rows.length;

        var status = 'available';
        if (_preSoldSeats.contains(seatId)) status = 'sold';
        if (_preLockedSeats.contains(seatId)) status = 'locked';

        var type = 'standard';
        if (isVipRow) type = 'vip';
        if (_wheelchairSeats.contains(seatId)) type = 'wheelchair';

        final seatJson = {
          'id': seatId,
          'sectionId': isVipRow ? 'vip' : 'standard',
          'rowLabel': row,
          'seatNumber': n,
          'x': x,
          'y': y,
          'type': type,
          'status': status,
          'price': isVipRow ? 18.0 : 12.0,
        };

        (isVipRow ? vipSeats : standardSeats).add(seatJson);
      }
    }

    return {
      'id': 'layout-demo-100',
      'venueId': 'demo-venue-1',
      'name': 'Generic 100-Seat Screen',
      'bookingMode': 'reserved_seating',
      'canvasWidth': 1000.0,
      'canvasHeight': 800.0,
      'sections': [
        {'id': 'vip', 'name': 'VIP', 'basePrice': 18.0, 'seats': vipSeats},
        {
          'id': 'standard',
          'name': 'Standard',
          'basePrice': 12.0,
          'seats': standardSeats,
        },
      ],
    };
  }
}
