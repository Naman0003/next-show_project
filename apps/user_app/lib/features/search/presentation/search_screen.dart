import 'dart:ui' as ui;

import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../discovery/presentation/cinema_theme.dart';
import '../application/ai_concierge_controller.dart';
import 'siri_waveform_widget.dart';

const _suggestions = [
  'I have 2 hours free',
  'I want something fun',
  'Movie tonight',
  'Find me a comedy show',
  'Something under €20',
  'Surprise me',
];

/// The AI concierge search screen — same dark cinematic language as
/// Discovery, since they sit side by side in the bottom nav (matches the
/// District reference's own AI-search screen, which shares its home
/// screen's dark theme). Purely a visual reskin: no controller or
/// navigation logic changed.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit(String query) {
    _textController.text = query;
    ref.read(aiConciergeControllerProvider.notifier).submitTextQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiConciergeControllerProvider);
    final notifier = ref.read(aiConciergeControllerProvider.notifier);
    final isListening = state.status == AiConciergeStatus.listening;

    if (isListening && _textController.text != state.transcript) {
      _textController.value = TextEditingValue(
        text: state.transcript,
        selection: TextSelection.collapsed(offset: state.transcript.length),
      );
    }

    return Scaffold(
      backgroundColor: CinemaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CinemaColors.textPrimary),
        title: Text(
          'Ask NextShow',
          style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.status == AiConciergeStatus.idle) ...[
              Text('👋 What are you in the mood for?', style: CinemaTextStyles.sectionHeader),
              const SizedBox(height: 6),
              Text(
                'Tell NextShow what you\'re up for, and it\'ll find the best options nearby.',
                style: CinemaTextStyles.meta,
              ),
              const SizedBox(height: 20),
            ],
            _GlassSearchBar(
              controller: _textController,
              isListening: isListening,
              onMicTap: () => isListening
                  ? notifier.stopListening()
                  : notifier.startListening(),
              onSubmitted: notifier.submitTextQuery,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isListening
                  ? Padding(
                      key: const ValueKey('waveform'),
                      padding: const EdgeInsets.only(top: 20),
                      child: SiriWaveformWidget(amplitude: state.soundLevel),
                    )
                  : const SizedBox(key: ValueKey('no-waveform')),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _ResultsArea(
                state: state,
                onRetry: notifier.reset,
                onSuggestionTap: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSearchBar extends StatelessWidget {
  const _GlassSearchBar({
    required this.controller,
    required this.isListening,
    required this.onMicTap,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMicTap;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: CinemaColors.glassFill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: CinemaColors.glassBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: NSColors.royalBlue.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: NSColors.skyBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: isListening,
                  onSubmitted: onSubmitted,
                  style: CinemaTextStyles.meta.copyWith(color: CinemaColors.textPrimary, fontSize: 15),
                  cursorColor: NSColors.skyBlue,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "I'm looking for...",
                    hintStyle: CinemaTextStyles.meta,
                    border: InputBorder.none,
                  ),
                ),
              ),
              NSPressScale(
                child: IconButton(
                  icon: Icon(
                    isListening ? Icons.stop_circle : Icons.mic_none,
                    color: NSColors.skyBlue,
                  ),
                  onPressed: onMicTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsArea extends StatelessWidget {
  const _ResultsArea({
    required this.state,
    required this.onRetry,
    required this.onSuggestionTap,
  });

  final AiConciergeState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AiConciergeStatus.idle:
        return _SuggestionList(onTap: onSuggestionTap);
      case AiConciergeStatus.listening:
        return CinemaEmptyState(
          icon: Icons.hearing,
          title: 'Listening…',
          subtitle: state.transcript.isEmpty ? 'Say what you\'re in the mood for.' : state.transcript,
        );
      case AiConciergeStatus.fetching:
        return ListView.separated(
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => Material(
            color: CinemaColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            child: const NSListItemSkeleton(
              baseColor: CinemaColors.surfaceElevated,
              highlightColor: CinemaColors.shimmerHighlight,
            ),
          ),
        );
      case AiConciergeStatus.error:
        return CinemaEmptyState(
          icon: Icons.error_outline,
          title: state.errorMessage ?? 'Something went wrong.',
          action: NSPrimaryButton(label: 'Try Again', onPressed: onRetry),
        );
      case AiConciergeStatus.success:
        if (state.results.isEmpty) {
          return const CinemaEmptyState(
            icon: Icons.search_off,
            title: 'No matches',
            subtitle: 'Try describing your mood differently.',
          );
        }
        return ListView(
          padding: EdgeInsets.only(bottom: AppTokens.dockClearance(context)),
          children: [
            for (final listing in state.results)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ResultCard(listing: listing),
              ),
          ].animate(interval: 70.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
        );
    }
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppTokens.dockClearance(context)),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final suggestion in _suggestions)
            NSPressScale(
              child: GestureDetector(
                onTap: () => onTap(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: CinemaColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CinemaColors.glassBorder),
                  ),
                  child: Text(
                    suggestion,
                    style: CinemaTextStyles.meta.copyWith(color: CinemaColors.textPrimary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.imageUrl ??
        'https://picsum.photos/seed/${listing.eventId}/200/300';

    return NSPressScale(
      child: Material(
        color: CinemaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => EventDetailRoute($extra: listing).push(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 56,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 78,
                      color: CinemaColors.background,
                      child: const Icon(Icons.event, color: CinemaColors.textMuted, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.eventTitle,
                        style: CinemaTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (listing.eventDescription != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          listing.eventDescription!,
                          style: CinemaTextStyles.meta,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${listing.venueName} · €${(listing.price ?? 0).toStringAsFixed(2)}',
                        style: CinemaTextStyles.meta.copyWith(
                          color: NSColors.skyBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: NSColors.skyBlue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
