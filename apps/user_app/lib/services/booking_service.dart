// lib/services/booking_service.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  static Future<void> launchBookingUrl(
      BuildContext context,
      String rawBookingUrl, {
        String? showtimeId,
      }) async {
    if (rawBookingUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No booking link available for this showtime.')),
      );
      return;
    }

    Uri uri = Uri.parse(rawBookingUrl);

    // Append tracking parameter to the booking link
    uri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'ref': 'nextshow',
      },
    );

    // 1. Record analytics click non-blockingly
    if (showtimeId != null) {
      Supabase.instance.client.from('outbound_clicks').insert({
        'showtime_id': showtimeId,
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      }).catchError((_) {});
    }

    // 2. Open external browser or cinema app
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open cinema booking link.')),
        );
      }
    }
  }
}