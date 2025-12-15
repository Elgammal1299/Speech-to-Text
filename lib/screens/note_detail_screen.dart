import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/voice_note.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Note Details',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _titleController.text = widget.note.title;
                  _textController.text = widget.note.text ?? '';
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.check, color: AppColors.success),
              onPressed: _saveChanges,
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.edit, color: theme.iconTheme.color),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: theme.iconTheme.color),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = widget.note.category != null
        ? Categories.getColor(widget.note.category)
        : colorScheme.primary;

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
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
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
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              widget.note.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatFullDate(widget.note.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
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
              Icon(Icons.notes, size: 20, color: theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Text(
                _isEditing ? 'Edit Notes' : 'Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextField(
              controller: _textController,
              maxLines: null,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
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
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            )
          else
            Text(
              'No notes',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
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
              Icon(Icons.info_outline, size: 20, color: theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Text(
                'Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
