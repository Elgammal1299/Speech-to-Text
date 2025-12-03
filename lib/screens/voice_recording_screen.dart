import 'package:flutter/material.dart';
import 'dart:async';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../models/voice_note.dart';
import '../models/category.dart';

class VoiceRecordingScreen extends StatefulWidget {
  final bool showAppBar;

  const VoiceRecordingScreen({super.key, this.showAppBar = true});

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();

  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _animationController;
  String? _currentRecordingPath;
  double _slideOffset = 0;
  final double _cancelThreshold = -100;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _checkPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _audioService.hasPermission();
    if (!hasPermission && mounted) {
      final granted = await _audioService.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _startTimer() {
    _recordingDuration = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    final path = await _audioService.startRecording();

    if (path != null) {
      setState(() {
        _isRecording = true;
        _currentRecordingPath = path;
        _slideOffset = 0;
      });
      _startTimer();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  Future<void> _stopRecording({bool save = true}) async {
    _stopTimer();
    final path = await _audioService.stopRecording();

    if (path != null && mounted) {
      setState(() {
        _isRecording = false;
        _currentRecordingPath = path;
      });

      if (save) {
        _showSaveDialog();
      } else {
        await _audioService.deleteAudioFile(path);
        setState(() {
          _currentRecordingPath = null;
          _recordingDuration = Duration.zero;
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    _stopTimer();
    await _audioService.cancelRecording();
    setState(() {
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
      _slideOffset = 0;
    });
  }

  Future<void> _showSaveDialog() async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedCategory;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Save Recording'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter recording title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add some notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Category (optional)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Categories.all.map((category) {
                          final isSelected = selectedCategory == category.name;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = isSelected ? null : category.name;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category.color.withValues(alpha: 0.2)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? category.color : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category.icon,
                                    size: 16,
                                    color: isSelected ? category.color : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected ? category.color : Colors.grey[700],
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_formatDuration(_recordingDuration)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Discard'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'title': titleController.text.trim(),
                  'notes': notesController.text.trim(),
                  'category': selectedCategory,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _saveRecording(
        result['title'],
        result['notes'],
        result['category'],
      );
    } else {
      if (_currentRecordingPath != null) {
        await _audioService.deleteAudioFile(_currentRecordingPath!);
      }
      setState(() {
        _currentRecordingPath = null;
        _recordingDuration = Duration.zero;
      });
    }

    titleController.dispose();
    notesController.dispose();
  }

  Future<void> _saveRecording(String title, String notes, String? category) async {
    if (_currentRecordingPath == null) return;

    final note = VoiceNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      text: notes.isEmpty ? null : notes,
      audioPath: _currentRecordingPath,
      createdAt: DateTime.now(),
      duration: _recordingDuration,
      category: category,
    );

    final success = await _storageService.saveNote(note);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _currentRecordingPath = null;
        _recordingDuration = Duration.zero;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                'Voice Recorder',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRecording) ...[
                    Icon(
                      Icons.mic_none,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hold to Record',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    _buildRecordingAnimation(),
                    const SizedBox(height: 32),
                    Text(
                      _formatDuration(_recordingDuration),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Recording controls at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _isRecording ? _buildRecordingControls() : _buildIdleControls(),
          ),
        ],
      ),
    );
  }


  Widget _buildRecordingAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3 * _animationController.value),
                blurRadius: 40,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(
                Icons.mic,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdleControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onLongPressEnd: (_) => _stopRecording(),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.blueAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.mic,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingControls() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _slideOffset += details.delta.dx;
          if (_slideOffset > 0) _slideOffset = 0;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_slideOffset < _cancelThreshold) {
          _cancelRecording();
        } else {
          setState(() => _slideOffset = 0);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cancel indicator
            if (_slideOffset < -20)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.delete,
                    color: _slideOffset < _cancelThreshold ? Colors.red : Colors.red.withValues(alpha: 0.5),
                    size: 28,
                  ),
                ),
              ),

            // Slide to cancel text
            Center(
              child: Opacity(
                opacity: _slideOffset > -50 ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Slide to cancel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recording button (movable)
            Positioned(
              right: 16 + _slideOffset,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _stopRecording(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
