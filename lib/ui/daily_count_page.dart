import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../models/exercise_model.dart';
import '../data/data_service.dart';

// Simple level buckets for UI
enum _Level { low, medium, high }

class DailyCountPage extends StatefulWidget {
  const DailyCountPage({super.key});

  @override
  State<DailyCountPage> createState() => _DailyCountPageState();
}

class _DailyCountPageState extends State<DailyCountPage> {
  final _dataService = DataService();
  List<FoodModel> _foods = [];
  List<ExerciseModel> _exercises = [];
  bool _isLoading = true;

  double? _weightKg;
  double? _heightCm;

  String _period = 'Today'; // Today | Week | Month

  _Level _foodLevel(FoodModel food) {
    final cals = food.calories;
    if (cals >= 600) return _Level.high;
    if (cals >= 300) return _Level.medium;
    return _Level.low;
  }

  _Level _exerciseLevel(ExerciseModel exercise) {
    final s = exercise.intensity.toLowerCase();
    if (s.contains('high') || s.contains('hard')) return _Level.high;
    if (s.contains('moderate') || s.contains('mid')) return _Level.medium;
    return _Level.low;
  }

  Color _levelColor(_Level level) {
    switch (level) {
      case _Level.high:
        return Colors.red;
      case _Level.medium:
        return Colors.orange;
      case _Level.low:
        return Colors.green;
    }
  }

  String _levelText(_Level level) {
    switch (level) {
      case _Level.high:
        return 'High';
      case _Level.medium:
        return 'Medium';
      case _Level.low:
        return 'Low';
    }
  }

  Widget _levelHeader(_Level level, int count) {
    final color = _levelColor(level);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${_levelText(level)} ($count)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final foods = await _dataService.loadFoods();
    final exercises = await _dataService.loadExercises();

    final profile = await _dataService.loadProfile();
    final weight = profile['weightKg'] as double?;
    final height = profile['heightCm'] as double?;

    if (!mounted) return;
    setState(() {
      _foods = foods;
      _exercises = exercises;
      _isLoading = false;
      _weightKg = (weight != null && weight > 0) ? weight : null;
      _heightCm = (height != null && height > 0) ? height : null;
    });
  }

  double? get _bmi {
    final w = _weightKg;
    final hCm = _heightCm;
    if (w == null || hCm == null) return null;
    final hM = hCm / 100.0;
    if (hM <= 0) return null;
    return w / (hM * hM);
  }

  String get _bmiText {
    final bmi = _bmi;
    if (bmi == null) return '-';
    return bmi.toStringAsFixed(1);
  }

  String get _bmiCategory {
    final bmi = _bmi;
    if (bmi == null) return '';
    if (bmi < 18.5) return 'Low';
    if (bmi < 25) return 'Fit';
    return 'High';
  }

  Color get _bmiCategoryColor {
    final bmi = _bmi;
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.grey;
    if (bmi < 25) return Colors.green;
    return Colors.red;
  }

  DateTime get _startDate {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (_period == 'Week') {
      // Monday start of week
      final diff = todayStart.weekday - DateTime.monday;
      return todayStart.subtract(Duration(days: diff));
    }
    if (_period == 'Month') {
      return DateTime(now.year, now.month, 1);
    }
    return todayStart;
  }

  List<FoodModel> get _filteredFoods {
    final start = _startDate;
    return _foods.where((f) => !f.savedAt.isBefore(start)).toList();
  }

  List<ExerciseModel> get _filteredExercises {
    final start = _startDate;
    return _exercises.where((e) => !e.savedAt.isBefore(start)).toList();
  }

  int get _totalCalories => _filteredFoods.fold(0, (sum, food) => sum + food.calories);
  int get _totalDuration => _filteredExercises.fold(0, (sum, ex) => sum + ex.duration);
  int get _estimatedCaloriesBurned => (_totalDuration * 5).toInt(); // Rough estimate

  @override
  Widget build(BuildContext context) {
    final netCalories = _totalCalories - _estimatedCaloriesBurned;

    final foods = _filteredFoods;
    final exercises = _filteredExercises;

    final foodHigh = foods.where((f) => _foodLevel(f) == _Level.high).toList();
    final foodMed = foods.where((f) => _foodLevel(f) == _Level.medium).toList();
    final foodLow = foods.where((f) => _foodLevel(f) == _Level.low).toList();

    final exHigh = exercises.where((e) => _exerciseLevel(e) == _Level.high).toList();
    final exMed = exercises.where((e) => _exerciseLevel(e) == _Level.medium).toList();
    final exLow = exercises.where((e) => _exerciseLevel(e) == _Level.low).toList();

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Daily Summary'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _period,
              items: const [
                DropdownMenuItem(value: 'Today', child: Text('Today')),
                DropdownMenuItem(value: 'Week', child: Text('This Week')),
                DropdownMenuItem(value: 'Month', child: Text('This Month')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _period = v);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calories In: $_totalCalories kcal'),
                        const SizedBox(height: 6),
                        Text('Exercise: $_totalDuration min'),
                        const SizedBox(height: 6),
                        Text('Estimated Burn: $_estimatedCaloriesBurned kcal'),
                        const SizedBox(height: 6),
                        Text(
                          'Net Calories: ${netCalories.abs()} kcal (${netCalories > 0 ? 'Surplus' : 'Deficit'})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('BMI: $_bmiText'),
                            if (_bmiCategory.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _bmiCategoryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _bmiCategory,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _bmiCategoryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_bmi == null) ...[
                          const SizedBox(height: 6),
                          const Text('Tip: Set weight & height in Me page'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Food Intake (${foods.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  foods.isEmpty
                      ? _buildEmptyState(icon: Icons.restaurant_menu, message: 'No food logged')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (foodHigh.isNotEmpty) ...[
                              _levelHeader(_Level.high, foodHigh.length),
                              ...foodHigh.map((f) => _simpleFoodTile(f)),
                            ],
                            if (foodMed.isNotEmpty) ...[
                              _levelHeader(_Level.medium, foodMed.length),
                              ...foodMed.map((f) => _simpleFoodTile(f)),
                            ],
                            if (foodLow.isNotEmpty) ...[
                              _levelHeader(_Level.low, foodLow.length),
                              ...foodLow.map((f) => _simpleFoodTile(f)),
                            ],
                          ],
                        ),

                  const SizedBox(height: 20),

                  Text(
                    'Exercise Activities (${exercises.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  exercises.isEmpty
                      ? _buildEmptyState(icon: Icons.directions_run, message: 'No exercise logged')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (exHigh.isNotEmpty) ...[
                              _levelHeader(_Level.high, exHigh.length),
                              ...exHigh.map((e) => _simpleExerciseTile(e)),
                            ],
                            if (exMed.isNotEmpty) ...[
                              _levelHeader(_Level.medium, exMed.length),
                              ...exMed.map((e) => _simpleExerciseTile(e)),
                            ],
                            if (exLow.isNotEmpty) ...[
                              _levelHeader(_Level.low, exLow.length),
                              ...exLow.map((e) => _simpleExerciseTile(e)),
                            ],
                          ],
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _simpleFoodTile(FoodModel food) {
    final level = _foodLevel(food);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.fastfood, color: _levelColor(level)),
      title: Text(food.foodType),
      subtitle: Text('${food.time} • ${food.calories} kcal'),
      trailing: Text(
        _levelText(level),
        style: TextStyle(fontWeight: FontWeight.bold, color: _levelColor(level)),
      ),
    );
  }

  Widget _simpleExerciseTile(ExerciseModel exercise) {
    final level = _exerciseLevel(exercise);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.directions_run, color: _levelColor(level)),
      title: Text(exercise.exerciseType),
      subtitle: Text('${exercise.duration} min • ${exercise.intensity}'),
      trailing: Text(
        _levelText(level),
        style: TextStyle(fontWeight: FontWeight.bold, color: _levelColor(level)),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Text(message),
        ],
      ),
    );
  }
}
