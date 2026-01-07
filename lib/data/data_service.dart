import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_model.dart';
import '../models/food_model.dart';

class DataService {
  static const String _foodsKey = 'foods';
  static const String _exercisesKey = 'exercises';
  static const String _profileKey = 'profile';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Map<String, dynamic> _defaultProfile() => {
        'name': '',
        'sex': 'Male',
        'dob': null,
        'weightKg': null,
        'heightCm': null,
      };

  DateTime? _tryParseDateTime(dynamic value) {
    if (value is! String) return null;
    if (value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  double? _toDoubleOrNull(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }

  List<FoodModel> _decodeFoods(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final foods = <FoodModel>[];
      for (final item in decoded) {
        if (item is Map) {
          foods.add(FoodModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return foods;
    } catch (_) {
      return [];
    }
  }

  List<ExerciseModel> _decodeExercises(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final exercises = <ExerciseModel>[];
      for (final item in decoded) {
        if (item is Map) {
          exercises.add(ExerciseModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return exercises;
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _decodeProfile(String? raw) {
    if (raw == null || raw.trim().isEmpty) return _defaultProfile();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return _defaultProfile();
      final map = Map<String, dynamic>.from(decoded);

      final profile = _defaultProfile();
      profile['name'] = (map['name'] ?? '') as String;
      profile['sex'] = (map['sex'] ?? 'Male') as String;
      profile['dob'] = _tryParseDateTime(map['dob']);
      profile['weightKg'] = _toDoubleOrNull(map['weightKg']);
      profile['heightCm'] = _toDoubleOrNull(map['heightCm']);
      return profile;
    } catch (_) {
      return _defaultProfile();
    }
  }

  // Food operations
  Future<List<FoodModel>> loadFoods() async {
    final prefs = await _prefs;
    return _decodeFoods(prefs.getString(_foodsKey));
  }

  Future<bool> saveFoods(List<FoodModel> foods) async {
    final prefs = await _prefs;
    final raw = jsonEncode(foods.map((f) => f.toJson()).toList());
    return prefs.setString(_foodsKey, raw);
  }

  Future<bool> addFood(FoodModel food) async {
    final foods = await loadFoods();
    foods.add(food);
    return await saveFoods(foods);
  }

  Future<bool> deleteFood(int index) async {
    final foods = await loadFoods();
    if (index >= 0 && index < foods.length) {
      foods.removeAt(index);
      return await saveFoods(foods);
    }
    return false;
  }

  // Exercise operations
  Future<List<ExerciseModel>> loadExercises() async {
    final prefs = await _prefs;
    return _decodeExercises(prefs.getString(_exercisesKey));
  }

  Future<bool> saveExercises(List<ExerciseModel> exercises) async {
    final prefs = await _prefs;
    final raw = jsonEncode(exercises.map((e) => e.toJson()).toList());
    return prefs.setString(_exercisesKey, raw);
  }

  Future<bool> addExercise(ExerciseModel exercise) async {
    final exercises = await loadExercises();
    exercises.add(exercise);
    return await saveExercises(exercises);
  }

  Future<bool> deleteExercise(int index) async {
    final exercises = await loadExercises();
    if (index >= 0 && index < exercises.length) {
      exercises.removeAt(index);
      return await saveExercises(exercises);
    }
    return false;
  }

  // Utility methods
  Future<bool> clearAllData() async {
    final prefs = await _prefs;
    final ok1 = await prefs.remove(_foodsKey);
    final ok2 = await prefs.remove(_exercisesKey);
    final ok3 = await prefs.remove(_profileKey);
    return ok1 && ok2 && ok3;
  }

  Future<Map<String, dynamic>> exportAllData() async {
    final foods = await loadFoods();
    final exercises = await loadExercises();
    final profile = await loadProfile();

    return {
      'foods': foods.map((f) => f.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'profile': {
        'name': profile['name'] as String,
        'sex': profile['sex'] as String,
        'dob': (profile['dob'] as DateTime?)?.toIso8601String(),
        'weightKg': profile['weightKg'] as double?,
        'heightCm': profile['heightCm'] as double?,
      },
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> loadProfile() async {
    final prefs = await _prefs;
    return _decodeProfile(prefs.getString(_profileKey));
  }

  Future<void> saveProfile({
    required String name,
    required String sex,
    required DateTime dob,
    required double weightKg,
    required double heightCm,
  }) async {
    final prefs = await _prefs;
    final raw = jsonEncode({
      'name': name,
      'sex': sex,
      'dob': dob.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
    });
    await prefs.setString(_profileKey, raw);
  }
}