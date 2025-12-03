import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;

  // Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Check if permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  // Start recording
  Future<String?> startRecording() async {
    try {
      // Check permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) return null;
      }

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/recording_$timestamp.m4a';

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecording = true;
      _currentRecordingPath = path;
      return path;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  // Stop recording
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      _isRecording = false;

      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _currentRecordingPath = null;
    } catch (e) {
      _isRecording = false;
    }
  }

  // Play audio file
  Future<void> playAudio(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
    }
  }

  // Resume audio
  Future<void> resumeAudio() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  // Stop audio
  Future<void> stopAudio() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
    }
  }

  // Get audio duration
  Future<Duration?> getAudioDuration(String path) async {
    try {
      await _player.setSource(DeviceFileSource(path));
      return await _player.getDuration();
    } catch (e) {
      return null;
    }
  }

  // Listen to player state
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  // Listen to player position
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  // Get current position
  Future<Duration> getCurrentPosition() async {
    return await _player.getCurrentPosition() ?? Duration.zero;
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Delete audio file
  Future<bool> deleteAudioFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
