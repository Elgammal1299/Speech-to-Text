import 'package:flutter/material.dart';

class NoteCategory {
  final String name;
  final IconData icon;
  final Color color;

  const NoteCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Categories {
  static const personal = NoteCategory(
    name: 'Personal',
    icon: Icons.person,
    color: Color(0xFF2196F3), // Blue
  );

  static const work = NoteCategory(
    name: 'Work',
    icon: Icons.work,
    color: Color(0xFFFF9800), // Orange
  );

  static const ideas = NoteCategory(
    name: 'Ideas',
    icon: Icons.lightbulb,
    color: Color(0xFFFFC107), // Amber
  );

  static const meetings = NoteCategory(
    name: 'Meetings',
    icon: Icons.groups,
    color: Color(0xFF9C27B0), // Purple
  );

  static const reminders = NoteCategory(
    name: 'Reminders',
    icon: Icons.notifications,
    color: Color(0xFFF44336), // Red
  );

  static const study = NoteCategory(
    name: 'Study',
    icon: Icons.school,
    color: Color(0xFF4CAF50), // Green
  );

  static const music = NoteCategory(
    name: 'Music',
    icon: Icons.music_note,
    color: Color(0xFFE91E63), // Pink
  );

  static const other = NoteCategory(
    name: 'Other',
    icon: Icons.folder,
    color: Color(0xFF607D8B), // Blue Grey
  );

  static const List<NoteCategory> all = [
    personal,
    work,
    ideas,
    meetings,
    reminders,
    study,
    music,
    other,
  ];

  static NoteCategory? fromName(String? name) {
    if (name == null) return null;
    try {
      return all.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }

  static Color getColor(String? categoryName) {
    final category = fromName(categoryName);
    return category?.color ?? Colors.grey;
  }

  static IconData getIcon(String? categoryName) {
    final category = fromName(categoryName);
    return category?.icon ?? Icons.folder;
  }
}
