import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool get isListening => _speechToText.isListening;

  Function(String)? _onStatusCallback;

  /// Initialize the speech recognition service
  Future<bool> initialize({Function(String)? onStatus}) async {
    try {
      _onStatusCallback = onStatus;
      _isInitialized = await _speechToText.initialize(
        onStatus: (status) {
          _onStatusCallback?.call(status);
        },
      );
      return _isInitialized;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      throw Exception('Speech service not initialized');
    }

    await _speechToText.listen(
      onResult: onResult,
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }

  /// Get available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    return await _speechToText.locales();
  }

  /// Check if speech recognition is available
  bool get isAvailable => _speechToText.isAvailable;
}
