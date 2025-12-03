import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/voice_note.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class NoteDetailScreen extends StatefulWidget {
  final VoiceNote note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();
  late TextEditingController _titleController;
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _textController = TextEditingController(text: widget.note.text ?? '');
    _totalDuration = widget.note.duration;
    _setupAudioListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioService.stopAudio();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _setupAudioListeners() {
    _positionSubscription = _audioService.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _stateSubscription = _audioService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (widget.note.audioPath == null) return;

    if (_isPlaying) {
      await _audioService.pauseAudio();
    } else {
      if (_currentPosition >= _totalDuration) {
        setState(() => _currentPosition = Duration.zero);
      }
      await _audioService.playAudio(widget.note.audioPath!);
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> _saveChanges() async {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      text: _textController.text.trim().isEmpty ? null : _textController.text.trim(),
    );

    final success = await _storageService.updateNote(updatedNote);
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
    }
  }

  Future<void> _copyText() async {
    final textToCopy = widget.note.text ?? widget.note.title;
    await Clipboard.setData(ClipboardData(text: textToCopy));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  String _formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y - h:mm a').format(date);
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Note Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _titleController.text = widget.note.title;
                  _textController.text = widget.note.text ?? '';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _saveChanges,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black54),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.black54),
              onPressed: _copyText,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.note.audioPath != null) _buildAudioPlayer(),
            _buildTitleCard(),
            if (widget.note.text != null || _isEditing) _buildTextContent(),
            _buildStatisticsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    final categoryColor = widget.note.category != null
        ? Categories.getColor(widget.note.category)
        : Colors.blue;

    final progress = _totalDuration.inSeconds > 0
        ? _currentPosition.inSeconds / _totalDuration.inSeconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: 0.1),
            categoryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Waveform visualization placeholder
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(40, (index) {
                final height = 15.0 + (index % 5) * 8.0;
                final isActive = (index / 40) <= progress;
                return Container(
                  width: 3,
                  height: height,
                  decoration: BoxDecoration(
                    color: isActive
                        ? categoryColor
                        : categoryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: categoryColor,
              inactiveTrackColor: categoryColor.withValues(alpha: 0.2),
              thumbColor: categoryColor,
              overlayColor: categoryColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _currentPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                _seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
          const SizedBox(height: 16),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip backward 10s
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColor.withValues(alpha: 0.1),
                ),
                child: IconButton(
                  onPressed: () {
                    final newPosition = _currentPosition - const Duration(seconds: 10);
                    _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
                  },
                  icon: const Icon(Icons.replay_10),
                  color: categoryColor,
                  iconSize: 28,
                ),
              ),
              const SizedBox(width: 24),
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor,
                      categoryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _togglePlayback,
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                  ),
                  color: Colors.white,
                  iconSize: 40,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(width: 24),
              // Skip forward 10s
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColor.withValues(alpha: 0.1),
                ),
                child: IconButton(
                  onPressed: () {
                    final newPosition = _currentPosition + const Duration(seconds: 10);
                    _seekTo(newPosition > _totalDuration ? _totalDuration : newPosition);
                  },
                  icon: const Icon(Icons.forward_10),
                  color: categoryColor,
                  iconSize: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              widget.note.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatFullDate(widget.note.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _isEditing ? 'Edit Notes' : 'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextField(
              controller: _textController,
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Add notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            )
          else if (widget.note.text != null)
            SelectableText(
              widget.note.text!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            )
          else
            Text(
              'No notes',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.access_time,
                  'Duration',
                  _formatDuration(widget.note.duration),
                  Colors.blue,
                ),
              ),
              if (widget.note.category != null)
                Expanded(
                  child: _buildStatItem(
                    Categories.getIcon(widget.note.category),
                    'Category',
                    widget.note.category!,
                    Categories.getColor(widget.note.category),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
