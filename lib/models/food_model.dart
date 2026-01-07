class FoodModel {
  final String foodType;
  final int calories;
  final String time;
  final DateTime savedAt;

  FoodModel({
    required this.foodType,
    required this.calories,
    required this.time,
    required this.savedAt,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) => FoodModel(
        foodType: json['foodType'] as String,
        calories: json['calories'] as int,
        time: json['time'] as String,
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
        'foodType': foodType,
        'calories': calories,
        'time': time,
      'savedAt': savedAt.toIso8601String(),
      };
}
