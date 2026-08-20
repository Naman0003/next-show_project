// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/ai_recommendation_service.dart';
import '../services/event_repository.dart';
import '../services/voice_input_service.dart';
import '../theme/app_theme.dart';
import '../widgets/account_menu_button.dart';
import '../widgets/voice_search_overlay.dart';
import 'browse_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  final EventRepository _eventRepository = EventRepository();

  bool _hasError = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isInputFocused = false;
  bool _voiceAvailable = false;
  String? _voiceErrorMessage;
  String _aiResponseText = "";
  List<AiPick> _picks = [];

  static const List<String> _suggestions = [
    "I have 2 hours free",
    "I want something fun",
    "Movie tonight",
    "Find me a comedy show",
    "Something under €20",
    "Surprise me",
  ];

  @override
  void initState() {
    super.initState();
    _promptFocusNode.addListener(() {
      setState(() => _isInputFocused = _promptFocusNode.hasFocus);
    });
    VoiceInputService.isAvailable().then((available) {
      if (mounted) setState(() => _voiceAvailable = available);
    });
  }

  Future<void> _openVoiceSearch() async {
    setState(() => _voiceErrorMessage = null);
    final result = await showVoiceSearchOverlay(context);
    if (!mounted) return;

    if (result.permissionDenied) {
      setState(() => _voiceErrorMessage = "Voice access denied — you can type instead.");
      return;
    }
    if (result.transcript != null && result.transcript!.isNotEmpty) {
      _submit(result.transcript!);
    }
  }

  @override
  void dispose() {
    _promptFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit(String userPrompt) async {
    if (userPrompt.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _hasSearched = true;
      _picks = [];
      _aiResponseText = "";
    });

    try {
      final liveEvents = await _eventRepository.fetchLiveEvents();
      if (liveEvents.isEmpty) {
        throw Exception("Nothing live in Berlin right now to recommend from.");
      }

      final result = await AiRecommendationService.recommend(
        userPrompt: userPrompt,
        liveEvents: liveEvents,
      );

      setState(() {
        _aiResponseText = result.intro;
        _picks = result.picks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _browse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BrowseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [AccountMenuButton()],
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _promptFocusNode.unfocus(),
          child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👋 Hello, welcome to NextShow", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      "What's on your mind today?",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Tell Next Show what you're up for, and it'll find the best options nearby.",
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promptController,
                            focusNode: _promptFocusNode,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "I'm looking for...",
                              hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                              filled: true,
                              fillColor: AppColors.iceBlue.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _voiceAvailable
                                  ? IconButton(
                                      icon: const Icon(Icons.mic_none, color: AppColors.royalBlue),
                                      onPressed: _openVoiceSearch,
                                    )
                                  : null,
                            ),
                            onSubmitted: _submit,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.royalBlue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            onPressed: () => _submit(_promptController.text),
                          ),
                        ),
                      ],
                    ),
                    if (_voiceErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _voiceErrorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_isLoading) ...[
                      const SizedBox(height: 24),
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: AppColors.royalBlue),
                            SizedBox(height: 16),
                            Text("Checking what's actually on in Berlin...", style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ] else if (_hasError) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage ?? "Couldn't get recommendations right now.",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.royalBlue),
                                onPressed: () => _submit(_promptController.text),
                                child: const Text("Try Again", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_picks.isNotEmpty) ...[
                      if (_aiResponseText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.iceBlue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.royalBlue.withOpacity(.3)),
                          ),
                          child: Text(
                            _aiResponseText,
                            style: const TextStyle(color: AppColors.royalBlue, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ..._picks.map((pick) => _PickCard(pick: pick)),
                    ] else ...[
                      if (_hasSearched)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "No matches found for that — try rephrasing.",
                            style: const TextStyle(color: Colors.black45),
                          ),
                        ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState:
                            _isInputFocused ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TRY ONE OF THESE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._suggestions.map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        side: const BorderSide(color: AppColors.border),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      ),
                                      onPressed: () {
                                        _promptController.text = s;
                                        _submit(s);
                                      },
                                      child: Text(s, style: const TextStyle(color: Colors.black87)),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                onPressed: _browse,
                child: Text(
                  "Just let me browse →",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final AiPick pick;

  const _PickCard({required this.pick});

  @override
  Widget build(BuildContext context) {
    final event = pick.event;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            event.imageUrl,
            width: 50,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 70,
              color: AppColors.border,
              child: const Icon(Icons.event, color: AppColors.royalBlue, size: 20),
            ),
          ),
        ),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              pick.reason,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "${event.venue} • €${event.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: AppColors.royalBlue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
          );
        },
      ),
    );
  }
}
