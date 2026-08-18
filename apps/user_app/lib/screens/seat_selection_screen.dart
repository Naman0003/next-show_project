// lib/screens/seat_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:user_app/models/event_model.dart';
import 'package:user_app/screens/payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Event event;
  final String cinemaName;
  final String showtime;

  const SeatSelectionScreen({
    Key? key,
    required this.event,
    required this.cinemaName,
    required this.showtime,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Grid representation: 0 = available, 1 = booked, 2 = selected
  final List<List<int>> _seats = [
    [0, 0, 1, 0, 0, 0, 1, 0],
    [0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 0, 0, 1],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 1, 0, 0],
  ];

  final Set<String> _selectedSeats = {};

  void _toggleSeat(int row, int col) {
    if (_seats[row][col] == 1) return; // Booked

    final seatId = "${String.fromCharCode(65 + row)}${col + 1}";
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
        _seats[row][col] = 0;
      } else {
        _selectedSeats.add(seatId);
        _seats[row][col] = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _selectedSeats.length * widget.event.price;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.event.title} • ${widget.showtime}"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            widget.cinemaName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Cinema Screen Visual
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text("SCREEN THIS WAY",
              style: TextStyle(
                  fontSize: 10, color: Colors.black45, letterSpacing: 2)),
          const SizedBox(height: 30),

          // Seat Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(Colors.white, "Available"),
              const SizedBox(width: 16),
              _buildLegend(Colors.grey.shade400, "Booked"),
              const SizedBox(width: 16),
              _buildLegend(const Color(0xFF6366F1), "Selected"),
            ],
          ),
          const SizedBox(height: 30),

          // Interactive Seat Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: List.generate(_seats.length, (rowIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          List.generate(_seats[rowIndex].length, (colIndex) {
                        final status = _seats[rowIndex][colIndex];
                        Color seatColor = Colors.white;
                        if (status == 1) seatColor = Colors.grey.shade300;
                        if (status == 2) seatColor = const Color(0xFF6366F1);

                        return GestureDetector(
                          onTap: () => _toggleSeat(rowIndex, colIndex),
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: seatColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: status == 2
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "${String.fromCharCode(65 + rowIndex)}${colIndex + 1}",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: status == 2
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_selectedSeats.length} Seats Selected",
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                Text("€${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669))),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedSeats.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FakePaymentScreen(
                            event: widget.event,
                            seats: _selectedSeats.toList().join(", "),
                            totalAmount: totalPrice,
                          ),
                        ),
                      );
                    },
              child: const Text("Pay Now",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
