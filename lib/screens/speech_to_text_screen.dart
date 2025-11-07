import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../services/speech_service.dart';
import '../models/speech_state.dart';
import '../models/language.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  SpeechState _state = const SpeechState();
  late AnimationController _animationController;
  Language _selectedLanguage = Language.english;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initializeSpeech();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    setState(() {
      _state = _state.copyWith(status: SpeechStatus.initializing);
    });

    final initialized = await _speechService.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            if (status == 'listening') {
              _state = _state.copyWith(status: SpeechStatus.listening);
            } else if (status == 'done' || status == 'notListening') {
              _state = _state.copyWith(status: SpeechStatus.ready);
            }
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        if (initialized) {
          _state = _state.copyWith(status: SpeechStatus.ready);
        } else {
          _state = _state.copyWith(
            status: SpeechStatus.error,
            errorMessage: 'Failed to initialize speech recognition',
          );
        }
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _state = _state.copyWith(
        recognizedText: result.recognizedWords,
        confidenceLevel: result.confidence,
      );
    });
  }

  Future<void> _toggleListening() async {
    if (_speechService.isListening) {
      await _speechService.stopListening();
      if (mounted) {
        setState(() {
          _state = _state.copyWith(status: SpeechStatus.ready);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _state = _state.copyWith(status: SpeechStatus.listening);
        });
      }
      try {
        await _speechService.startListening(
          onResult: _onSpeechResult,
          localeId: _selectedLanguage.localeId,
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _state = _state.copyWith(
              status: SpeechStatus.error,
              errorMessage: e.toString(),
            );
          });
        }
      }
    }
  }

  void _changeLanguage(Language language) {
    if (_speechService.isListening) {
      _speechService.stopListening();
    }
    setState(() {
      _selectedLanguage = language;
      _state = _state.copyWith(
        recognizedText: '',
        confidenceLevel: 0.0,
        status: SpeechStatus.ready,
      );
    });
  }

  void _clearText() {
    setState(() {
      _state = _state.copyWith(recognizedText: '', confidenceLevel: 0.0);
    });
  }

  Future<void> _copyText() async {
    if (_state.recognizedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _state.recognizedText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text copied to clipboard'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getStatusColor() {
    switch (_state.status) {
      case SpeechStatus.listening:
        return Colors.green;
      case SpeechStatus.error:
        return Colors.red;
      case SpeechStatus.ready:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getMicIcon() {
    if (_state.status == SpeechStatus.listening) {
      return Icons.mic;
    }
    return Icons.mic_none;
  }

  String _getStatusText() {
    switch (_state.status) {
      case SpeechStatus.idle:
        return 'Not initialized';
      case SpeechStatus.initializing:
        return 'Initializing...';
      case SpeechStatus.ready:
        return 'Ready to listen';
      case SpeechStatus.listening:
        return 'Listening...';
      case SpeechStatus.processing:
        return 'Processing...';
      case SpeechStatus.error:
        return 'Error: ${_state.errorMessage}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Speech to Text',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildLanguageSelector(),
          if (_state.recognizedText.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.black54),
              onPressed: _copyText,
              tooltip: 'Copy text',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black54),
              onPressed: _clearText,
              tooltip: 'Clear text',
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusCard(),
            Expanded(
              child: _buildTextDisplay(),
            ),
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: Language.values.map((language) {
          final isSelected = _selectedLanguage == language;
          return GestureDetector(
            onTap: () => _changeLanguage(language),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                language.shortCode,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getStatusText(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_state.confidenceLevel > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(_state.confidenceLevel * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Recognized Text',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_state.recognizedText.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic_none_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap the microphone to start',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SelectableText(
                _state.recognizedText,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    final isListening = _state.status == SpeechStatus.listening;
    final canListen = _state.status == SpeechStatus.ready ||
        _state.status == SpeechStatus.listening;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isListening)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final animation = Tween<double>(begin: 0.3, end: 1.0)
                          .animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            delay,
                            delay + 0.6,
                            curve: Curves.easeInOut,
                          ),
                        ),
                      );
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 24 * animation.value,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          GestureDetector(
            onTap: canListen ? _toggleListening : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: canListen
                      ? (isListening
                          ? [Colors.green, Colors.green.shade700]
                          : [Colors.blue, Colors.blue.shade700])
                      : [Colors.grey, Colors.grey.shade600],
                ),
                boxShadow: [
                  if (canListen)
                    BoxShadow(
                      color: (isListening ? Colors.green : Colors.blue)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Icon(
                _getMicIcon(),
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isListening ? 'Tap to stop' : 'Tap to speak',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
