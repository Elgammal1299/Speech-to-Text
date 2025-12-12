import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentTranscription = '';
  double _confidence = 0.0;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get currentTranscription => _currentTranscription;
  double get confidence => _confidence;

  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          // Error handling - could use a logging framework in production
        },
        onStatus: (status) {
          _isListening = status == 'listening';
        },
      );
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  // Start listening with callback for real-time transcription
  Future<bool> startListening({
    required Function(String) onResult,
    String localeId = 'en_US', // Default to English, can be 'ar_SA' for Arabic
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    // Check if speech recognition is available
    if (!await _speech.hasPermission) {
      return false;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          _currentTranscription = result.recognizedWords;
          _confidence = result.confidence;
          onResult(_currentTranscription);
        },
        localeId: localeId,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true, // Get real-time partial results
        ),
      );
      _isListening = true;
      return true;
    } catch (e) {
      // Error handling - in production, use proper logging
      return false;
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      _currentTranscription = '';
      _confidence = 0.0;
    }
  }

  // Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speech.locales();
  }

  // Check if locale is available
  Future<bool> isLocaleAvailable(String localeId) async {
    final locales = await getAvailableLocales();
    return locales.any((locale) => locale.localeId == localeId);
  }

  // Reset transcription
  void reset() {
    _currentTranscription = '';
    _confidence = 0.0;
  }

  // Dispose
  void dispose() {
    _speech.stop();
  }
}
