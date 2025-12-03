import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_note.dart';

class StorageService {
  static const String _notesKey = 'voice_notes';
  static const String _autoSaveKey = 'auto_save';
  static const String _themeKey = 'dark_theme';

  // Save a voice note
  Future<bool> saveNote(VoiceNote note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getAllNotes();
      notes.insert(0, note); // Add to beginning of list

      final notesJson = notes.map((n) => n.toJson()).toList();
      final jsonString = jsonEncode(notesJson);

      return await prefs.setString(_notesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Get all voice notes
  Future<List<VoiceNote>> getAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => VoiceNote.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete a voice note
  Future<bool> deleteNote(String noteId) async {
    try {
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == noteId);

      final prefs = await SharedPreferences.getInstance();
      final notesJson = notes.map((n) => n.toJson()).toList();
      final jsonString = jsonEncode(notesJson);

      return await prefs.setString(_notesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Update a voice note
  Future<bool> updateNote(VoiceNote updatedNote) async {
    try {
      final notes = await getAllNotes();
      final index = notes.indexWhere((note) => note.id == updatedNote.id);

      if (index != -1) {
        notes[index] = updatedNote;

        final prefs = await SharedPreferences.getInstance();
        final notesJson = notes.map((n) => n.toJson()).toList();
        final jsonString = jsonEncode(notesJson);

        return await prefs.setString(_notesKey, jsonString);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get notes by category
  Future<List<VoiceNote>> getNotesByCategory(String? category) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.category == category).toList();
  }

  // Search notes
  Future<List<VoiceNote>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    final lowerQuery = query.toLowerCase();
    return allNotes
        .where((note) =>
            note.title.toLowerCase().contains(lowerQuery) ||
            (note.text?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  // Clear all notes
  Future<bool> clearAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_notesKey);
    } catch (e) {
      return false;
    }
  }

  // Settings methods
  Future<bool> setAutoSave(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_autoSaveKey, value);
  }

  Future<bool> getAutoSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSaveKey) ?? true;
  }

  Future<bool> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_themeKey, value);
  }

  Future<bool> getDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Statistics methods
  Future<Map<String, dynamic>> getStatistics() async {
    final notes = await getAllNotes();

    if (notes.isEmpty) {
      return {
        'totalNotes': 0,
        'totalDuration': Duration.zero,
        'averageDuration': Duration.zero,
        'categoryBreakdown': <String, int>{},
        'notesThisWeek': 0,
        'notesThisMonth': 0,
        'mostUsedCategory': 'N/A',
      };
    }

    final totalDuration = notes.fold<Duration>(
      Duration.zero,
      (sum, note) => sum + note.duration,
    );
    final averageDuration = Duration(
      seconds: totalDuration.inSeconds ~/ notes.length,
    );

    final categoryBreakdown = <String, int>{};
    for (var note in notes) {
      final category = note.category ?? 'Uncategorized';
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + 1;
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final notesThisWeek = notes.where((note) => note.createdAt.isAfter(weekAgo)).length;
    final notesThisMonth = notes.where((note) => note.createdAt.isAfter(monthAgo)).length;

    return {
      'totalNotes': notes.length,
      'totalDuration': totalDuration,
      'averageDuration': averageDuration,
      'categoryBreakdown': categoryBreakdown,
      'notesThisWeek': notesThisWeek,
      'notesThisMonth': notesThisMonth,
      'mostUsedCategory': categoryBreakdown.entries.isEmpty
          ? 'N/A'
          : categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key,
    };
  }
}
