// lib/services/voice_input_service.dart
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceStopReason { silence, permissionDenied, error }

/// Thin wrapper around `speech_to_text`. On Flutter web this is backed by
/// the browser's real Web Speech API; on iOS/Android it uses the native
/// platform speech recognizer — same Dart surface either way.
class VoiceInputService {
  static final SpeechToText _speech = SpeechToText();
  static bool _initialized = false;
  static void Function(VoiceStopReason reason)? _activeOnDone;

  /// Whether voice input can be offered on this platform at all. Used to
  /// decide whether to show the mic icon in the first place — does not
  /// itself start listening or necessarily prompt for permission.
  static Future<bool> isAvailable() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(onError: _handleError, onStatus: (_) {});
    return _initialized;
  }

  static void _handleError(SpeechRecognitionError error) {
    // "not-allowed" is the Web Speech API's mic-permission-denied code;
    // "error_permission" is the native Android/iOS equivalent.
    final isPermissionDenied =
        error.errorMsg.contains('not-allowed') || error.errorMsg == 'error_permission';
    _activeOnDone?.call(isPermissionDenied ? VoiceStopReason.permissionDenied : VoiceStopReason.error);
    _activeOnDone = null;
  }

  /// Starts listening. [onResult] fires on every partial and final
  /// transcript. [onDone] fires exactly once when listening stops, either
  /// from ~2s of silence or an error (permission denial reported
  /// distinctly so the caller can show the right message).
  static Future<void> listen({
    required void Function(String transcript, bool isFinal) onResult,
    void Function(double level)? onSoundLevelChange,
    required void Function(VoiceStopReason reason) onDone,
  }) async {
    final ready = _initialized || await isAvailable();
    if (!ready) {
      onDone(VoiceStopReason.error);
      return;
    }

    _activeOnDone = onDone;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult && _activeOnDone != null) {
          _activeOnDone!(VoiceStopReason.silence);
          _activeOnDone = null;
        }
      },
      onSoundLevelChange: (level) => onSoundLevelChange?.call(level),
      listenOptions: SpeechListenOptions(
        pauseFor: const Duration(seconds: 2),
        listenFor: const Duration(seconds: 30),
      ),
    );
  }

  /// Gracefully ends listening once the caller has already decided to
  /// submit (e.g. its own silence timer fired) — unlike [cancel], this
  /// still lets the platform flush a final result if it's going to.
  /// No [onDone] fires after this; the caller already knows the outcome.
  static Future<void> stop() async {
    _activeOnDone = null;
    await _speech.stop();
  }

  /// Stops listening without treating it as a submission and discards
  /// anything in flight — no [onDone] fires after this, the caller (the
  /// overlay's close button) already knows it cancelled.
  static Future<void> cancel() async {
    _activeOnDone = null;
    await _speech.cancel();
  }
}
