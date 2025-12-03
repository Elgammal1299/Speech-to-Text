class VoiceNote {
  final String id;
  final String title;
  final String? text;
  final String? audioPath;
  final DateTime createdAt;
  final Duration duration;
  final String? category;

  VoiceNote({
    required this.id,
    required this.title,
    this.text,
    this.audioPath,
    required this.createdAt,
    required this.duration,
    this.category,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'audioPath': audioPath,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inSeconds,
      'category': category,
    };
  }

  // Create from JSON
  factory VoiceNote.fromJson(Map<String, dynamic> json) {
    return VoiceNote(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String?,
      audioPath: json['audioPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      category: json['category'] as String?,
    );
  }

  // Create a copy with modified fields
  VoiceNote copyWith({
    String? id,
    String? title,
    String? text,
    String? audioPath,
    DateTime? createdAt,
    Duration? duration,
    String? category,
  }) {
    return VoiceNote(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Get preview text (first 50 characters)
  String get preview {
    if (text == null || text!.isEmpty) return 'Audio recording';
    if (text!.length <= 50) return text!;
    return '${text!.substring(0, 50)}...';
  }

  // Get formatted duration
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
