class ExerciseModel {
  final String exerciseType;
  final int duration;
  final String intensity;
  final DateTime savedAt;

  ExerciseModel({
    required this.exerciseType,
    required this.duration,
    required this.intensity,
    required this.savedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        exerciseType: json['exerciseType'] as String,
        duration: json['duration'] as int,
        intensity: json['intensity'] as String,
        savedAt: _parseSavedAt(json['savedAt']),
      );

  static DateTime _parseSavedAt(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'exerciseType': exerciseType,
        'duration': duration,
        'intensity': intensity,
      'savedAt': savedAt.toIso8601String(),
      };
}
