enum SpeechStatus {
  idle,
  initializing,
  ready,
  listening,
  processing,
  error,
}

class SpeechState {
  final SpeechStatus status;
  final String recognizedText;
  final String errorMessage;
  final double confidenceLevel;

  const SpeechState({
    this.status = SpeechStatus.idle,
    this.recognizedText = '',
    this.errorMessage = '',
    this.confidenceLevel = 0.0,
  });

  SpeechState copyWith({
    SpeechStatus? status,
    String? recognizedText,
    String? errorMessage,
    double? confidenceLevel,
  }) {
    return SpeechState(
      status: status ?? this.status,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    );
  }
}
