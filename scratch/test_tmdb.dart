import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  final endpoints = [
    'https://api.themoviedb.org/3/search/movie?api_key=e772a98cf2e033252424c6016d2c16f0&query=Inception',
    'https://api.tmdb.org/3/search/movie?api_key=e772a98cf2e033252424c6016d2c16f0&query=Inception',
  ];

  for (final url in endpoints) {
    try {
      print('Testing: $url');
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
      req.headers.set('Accept', 'application/json');
      final res = await req.close();
      print('Status: ${res.statusCode}');
      final body = await res.transform(utf8.decoder).join();
      print('Body sample: ${body.substring(0, 100)}...\n');
    } catch (e) {
      print('Failed: $e\n');
    }
  }
}
