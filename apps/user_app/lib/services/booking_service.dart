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
    String cleanUrl = rawBookingUrl.trim();
    if (cleanUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No booking link available for this showtime.')),
      );
      return;
    }

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    Uri uri = Uri.parse(cleanUrl);

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
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open cinema booking link: $cleanUrl')),
        );
      }
    }
  }
}
