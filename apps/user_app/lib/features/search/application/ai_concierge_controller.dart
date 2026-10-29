import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/voice_input_service.dart';
import '../data/ai_concierge_service.dart';

part 'ai_concierge_controller.g.dart';

/// Swapping in [SupabaseAiConciergeService] once the edge function is
/// deployed is a one-line override of this provider — same DI seam used for
/// the Hive box providers.
final aiConciergeServiceProvider = Provider<AiConciergeService>((ref) {
  return const MockAiConciergeService();
});

enum AiConciergeStatus { idle, listening, fetching, success, error }

class AiConciergeState {
  const AiConciergeState({
    this.status = AiConciergeStatus.idle,
    this.transcript = '',
    this.soundLevel = 0,
    this.results = const [],
    this.errorMessage,
  });

  final AiConciergeStatus status;
  final String transcript;
  final double soundLevel;
  final List<Listing> results;
  final String? errorMessage;

  AiConciergeState copyWith({
    AiConciergeStatus? status,
    String? transcript,
    double? soundLevel,
    List<Listing>? results,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiConciergeState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      soundLevel: soundLevel ?? this.soundLevel,
      results: results ?? this.results,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Idle -> Listening (voice) -> Fetching -> Success, with Error reachable
/// from either Listening (mic permission/recognition failure) or Fetching
/// (search failure).
@riverpod
class AiConciergeController extends _$AiConciergeController {
  @override
  AiConciergeState build() => const AiConciergeState();

  AiConciergeService get _service => ref.read(aiConciergeServiceProvider);

  Future<void> startListening() async {
    state = const AiConciergeState(status: AiConciergeStatus.listening);

    await VoiceInputService.listen(
      onResult: (transcript, isFinal) {
        state = state.copyWith(transcript: transcript);
      },
      onSoundLevelChange: (level) {
        state = state.copyWith(
            soundLevel: VoiceInputService.normalizeSoundLevel(level));
      },
      onDone: (reason) {
        if (state.status != AiConciergeStatus.listening) return;
        switch (reason) {
          case VoiceStopReason.silence:
            _finishListening();
            break;
          case VoiceStopReason.permissionDenied:
            state = state.copyWith(
              status: AiConciergeStatus.error,
              errorMessage: 'Microphone access was denied.',
            );
            break;
          case VoiceStopReason.error:
            state = state.copyWith(
              status: AiConciergeStatus.error,
              errorMessage: "Didn't catch that — try again.",
            );
            break;
        }
      },
    );
  }

  /// Stops listening and submits whatever transcript has been captured so
  /// far (e.g. the user tapped the mic again instead of waiting it out).
  Future<void> stopListening() async {
    if (state.status != AiConciergeStatus.listening) return;
    await VoiceInputService.stop();
    await _finishListening();
  }

  /// Shared tail of both listening-stopped paths: submit whatever transcript
  /// was captured, or reset to idle if nothing was said.
  Future<void> _finishListening() async {
    final query = state.transcript.trim();
    if (query.isEmpty) {
      state = const AiConciergeState();
    } else {
      await _runSearch(query);
    }
  }

  Future<void> submitTextQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    if (state.status == AiConciergeStatus.listening) {
      await VoiceInputService.cancel();
    }
    await _runSearch(trimmed);
  }

  void reset() => state = const AiConciergeState();

  Future<void> _runSearch(String query) async {
    state =
        state.copyWith(status: AiConciergeStatus.fetching, transcript: query);
    try {
      final results = await _service.search(query);
      state =
          state.copyWith(status: AiConciergeStatus.success, results: results);
    } catch (_) {
      state = state.copyWith(
        status: AiConciergeStatus.error,
        errorMessage: "Search didn't go through — try again.",
      );
    }
  }
}
