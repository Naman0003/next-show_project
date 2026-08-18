// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:user_app/models/event_model.dart';

class FakePaymentScreen extends StatefulWidget {
  final Event event;
  final String seats;
  final double totalAmount;

  const FakePaymentScreen({
    Key? key,
    required this.event,
    required this.seats,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<FakePaymentScreen> createState() => _FakePaymentScreenState();
}

class _FakePaymentScreenState extends State<FakePaymentScreen> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  void _processPayment() {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: _isSuccess
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF059669), size: 90),
                    const SizedBox(height: 16),
                    const Text("Booking Confirmed!",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Seats: ${widget.seats}",
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1)),
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text("Back to Home",
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Seats: ${widget.seats}",
                      style: const TextStyle(color: Colors.black54)),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("€${widget.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669))),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isProcessing ? null : _processPayment,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Complete Demo Payment",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
