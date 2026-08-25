import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Appends NextShow's own tracking params on top of whatever the partner's
/// booking URL already carries, so we can attribute clicks without touching
/// their query string.
Uri _withUtmParams(String destinationUrl) {
  final uri = Uri.parse(destinationUrl);
  return uri.replace(queryParameters: {
    ...uri.queryParameters,
    'utm_source': 'nextshow',
    'utm_medium': 'app',
    'device_platform': 'app',
  });
}

class BookingWebViewScreen extends StatefulWidget {
  const BookingWebViewScreen({
    super.key,
    required this.destinationUrl,
    this.eventTitle,
  });

  final String destinationUrl;
  final String? eventTitle;

  @override
  State<BookingWebViewScreen> createState() => _BookingWebViewScreenState();
}

class _BookingWebViewScreenState extends State<BookingWebViewScreen> {
  late final Uri _trackedUri = _withUtmParams(widget.destinationUrl);
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _loadFailed = false;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            // Sub-resource errors (analytics pixels, fonts, etc.) shouldn't
            // fail the whole page — only bail out when the main frame itself
            // couldn't load, which is how X-Frame-Options / CSP
            // frame-ancestors blocks surface here.
            if (error.isForMainFrame == false) return;
            setState(() {
              _isLoading = false;
              _loadFailed = true;
            });
          },
        ),
      )
      ..loadRequest(_trackedUri);
  }

  Future<void> _openExternally() async {
    await launchUrl(_trackedUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventTitle ?? 'Book tickets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Return to NextShow',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
            onPressed: _openExternally,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_loadFailed) WebViewWidget(controller: _controller),
          if (_isLoading && !_loadFailed) const NSLoading(message: 'Loading booking page…'),
          if (_loadFailed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.block, size: 48, color: NSColors.error),
                    const SizedBox(height: 16),
                    Text(
                      "This booking page can't be embedded here.",
                      style: NSTextStyles.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    NSPrimaryButton(
                      label: 'Open in Browser',
                      icon: Icons.open_in_browser,
                      onPressed: _openExternally,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
