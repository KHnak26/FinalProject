import 'package:flutter/material.dart';
import '../data/data_service.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final _dataService = DataService();
  // Profile
  String? _userName;
  double? _weight;
  double? _height;

  double? get _bmi {
    final w = _weight;
    final hCm = _height;
    if (w == null || hCm == null) return null;
    if (w <= 0 || hCm <= 0) return null;
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

  // UI selections
  String _type = 'Workout'; // Workout | Food
  String? _goal = 'Lose Weight'; // Lose Weight | Build Muscle | General Fitness | Maintain
  String _activity = 'Low'; // Low | Medium | High (food only)

  // Outputs
  List<Map<String, dynamic>> _workoutRecs = [];
  int? _dailyTargetKcal;
  List<Map<String, dynamic>> _mealPlan = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _generate();
  }

  Future<void> _loadUserProfile() async {
    final data = await _dataService.loadProfile();
    if (!mounted) return;

    setState(() {
      final name = (data['name'] as String?) ?? '';
      _userName = name.isEmpty ? null : name;
      _weight = data['weightKg'] as double?;
      _height = data['heightCm'] as double?;
    });
  }

  bool get _hasProfile {
    return _userName != null &&
        _userName!.trim().isNotEmpty &&
        _weight != null &&
        _weight! > 0 &&
        _height != null &&
        _height! > 0;
  }

  void _generate() {
    if (_goal == null) return;

    if (_type == 'Workout') {
      setState(() {
        _dailyTargetKcal = null;
        _mealPlan = [];
        _workoutRecs = _buildWorkoutRecommendations(_goal!);
      });
      return;
    }

    // Food
    if (!_hasProfile) return;

    setState(() {
      _workoutRecs = [];
      _dailyTargetKcal = _calcDailyTargetKcal();
      _mealPlan = _buildMealPlan(_goal!);
    });
  }

  List<Map<String, dynamic>> _buildWorkoutRecommendations(String goal) {
    if (goal == 'Lose Weight') {
      return [
        {
          'title': 'Cardio Training',
          'description': 'High-intensity cardio to burn calories',
          'items': [
            'Running: 30-45 minutes, 3-4 times per week',
            'Jump Rope: 15-20 minutes daily',
            'Cycling: 45-60 minutes, 3 times per week',
            'Swimming: 30-40 minutes, 2-3 times per week',
          ],
          'icon': Icons.directions_run,
          'color': Colors.orange,
        },
        {
          'title': 'HIIT Workouts',
          'description': 'Burn fat with high-intensity intervals',
          'items': [
            'Burpees: 3 sets of 15 reps',
            'Mountain Climbers: 3 sets of 20 reps',
            'High Knees: 3 sets of 30 seconds',
            'Jumping Jacks: 3 sets of 30 reps',
          ],
          'icon': Icons.flash_on,
          'color': Colors.red,
        },
        {
          'title': 'Circuit Training',
          'description': 'Full-body fat burning circuits',
          'items': [
            'Squats: 3 sets of 20 reps',
            'Push-ups: 3 sets of 15 reps',
            'Lunges: 3 sets of 15 reps per leg',
            'Plank: 3 sets of 45 seconds',
          ],
          'icon': Icons.fitness_center,
          'color': Colors.deepOrange,
        },
        {
          'title': 'Walking & Recovery',
          'description': 'Low-impact fat burning',
          'items': [
            'Brisk Walking: 45-60 minutes daily',
            'Yoga: 20-30 minutes, 2-3 times per week',
            'Stretching: 10-15 minutes daily',
          ],
          'icon': Icons.self_improvement,
          'color': Colors.green,
        },
      ];
    }

    if (goal == 'Build Muscle') {
      return [
        {
          'title': 'Strength Training',
          'description': 'Build muscle with resistance exercises',
          'items': [
            'Bench Press: 4 sets of 8-12 reps',
            'Squats: 4 sets of 8-12 reps',
            'Deadlifts: 4 sets of 6-10 reps',
            'Overhead Press: 3 sets of 8-12 reps',
          ],
          'icon': Icons.fitness_center,
          'color': Colors.blue,
        },
        {
          'title': 'Upper Body',
          'description': 'Build chest, back, and arm muscles',
          'items': [
            'Pull-ups: 4 sets of 8-12 reps',
            'Bent-over Rows: 4 sets of 10-12 reps',
            'Bicep Curls: 3 sets of 12-15 reps',
            'Tricep Dips: 3 sets of 10-15 reps',
          ],
          'icon': Icons.accessibility_new,
          'color': Colors.indigo,
        },
        {
          'title': 'Lower Body',
          'description': 'Build leg and glute muscles',
          'items': [
            'Leg Press: 4 sets of 10-12 reps',
            'Lunges: 3 sets of 12 reps per leg',
            'Leg Curls: 3 sets of 12-15 reps',
            'Calf Raises: 4 sets of 15-20 reps',
          ],
          'icon': Icons.directions_walk,
          'color': Colors.purple,
        },
        {
          'title': 'Core Strength',
          'description': 'Build abdominal and core muscles',
          'items': [
            'Weighted Crunches: 3 sets of 15-20 reps',
            'Russian Twists: 3 sets of 20 reps',
            'Hanging Leg Raises: 3 sets of 10-15 reps',
            'Plank: 3 sets of 60 seconds',
          ],
          'icon': Icons.sports_gymnastics,
          'color': Colors.teal,
        },
      ];
    }

    // General Fitness
    return [
      {
        'title': 'Balanced Cardio',
        'description': 'Maintain cardiovascular health',
        'items': [
          'Jogging: 20-30 minutes, 3 times per week',
          'Cycling: 30 minutes, 2 times per week',
          'Swimming: 20-30 minutes, once per week',
        ],
        'icon': Icons.favorite,
        'color': Colors.pink,
      },
      {
        'title': 'Full Body Workout',
        'description': 'Overall fitness and toning',
        'items': [
          'Squats: 3 sets of 15 reps',
          'Push-ups: 3 sets of 12 reps',
          'Lunges: 3 sets of 12 reps per leg',
          'Pull-ups: 3 sets of 8 reps',
        ],
        'icon': Icons.fitness_center,
        'color': Colors.cyan,
      },
      {
        'title': 'Flexibility & Balance',
        'description': 'Improve mobility and stability',
        'items': [
          'Yoga: 30 minutes, 3 times per week',
          'Dynamic Stretching: 15 minutes daily',
          'Balance Exercises: 10 minutes, 3 times per week',
        ],
        'icon': Icons.self_improvement,
        'color': Colors.lightGreen,
      },
    ];
  }

  double _activityFactor() {
    switch (_activity) {
      case 'Medium':
        return 1.1;
      case 'High':
        return 1.2;
      case 'Low':
      default:
        return 1.0;
    }
  }

  int _calcDailyTargetKcal() {
    final w = _weight ?? 0;
    // Simple lesson-friendly estimate from weight.
    final base = (w * 30).round();
    final targetBase = (base * _activityFactor()).round();

    double goalAdjust = 0;
    if (_goal == 'Lose Weight') goalAdjust = -400;
    if (_goal == 'Build Muscle') goalAdjust = 300;
    if (_goal == 'Maintain') goalAdjust = 0;

    final target = targetBase + goalAdjust.round();
    if (target < 1200) return 1200;
    return target;
  }

  Map<String, dynamic> _meal(String title, List<String> foods, int totalKcal) {
    final count = foods.isEmpty ? 1 : foods.length;
    final base = totalKcal ~/ count;
    int remain = totalKcal - base * count;

    final items = <Map<String, dynamic>>[];
    for (final name in foods) {
      final add = remain > 0 ? 1 : 0;
      if (remain > 0) remain -= 1;
      items.add({'name': name, 'kcal': base + add});
    }

    return {'title': title, 'totalKcal': totalKcal, 'items': items};
  }

  List<Map<String, dynamic>> _buildMealPlan(String goal) {
    final daily = _dailyTargetKcal;
    if (daily == null) return [];

    final breakfast = (daily * 0.25).round();
    final lunch = (daily * 0.35).round();
    final dinner = (daily * 0.30).round();
    final snacks = daily - breakfast - lunch - dinner;

    List<String> breakfastFoods;
    List<String> lunchFoods;
    List<String> dinnerFoods;
    List<String> snackFoods;

    if (goal == 'Lose Weight') {
      breakfastFoods = ['Greek yogurt', 'Berries', 'Boiled eggs'];
      lunchFoods = ['Grilled chicken salad', 'Olive oil (small)', 'Fruit'];
      dinnerFoods = ['Fish or chicken', 'Steamed vegetables', 'Small rice'];
      snackFoods = ['Apple', 'Cucumber', 'Nuts (small)'];
    } else if (goal == 'Build Muscle') {
      breakfastFoods = ['Oats + milk', 'Eggs', 'Banana'];
      lunchFoods = ['Rice or pasta', 'Chicken/beef', 'Vegetables'];
      dinnerFoods = ['Potatoes or rice', 'Tuna/chicken', 'Salad'];
      snackFoods = ['Yogurt', 'Peanut butter sandwich', 'Milk'];
    } else {
      breakfastFoods = ['Oats', 'Fruit', 'Milk'];
      lunchFoods = ['Protein (chicken/fish/beans)', 'Carbs (rice/bread)', 'Vegetables'];
      dinnerFoods = ['Lean protein', 'Vegetables', 'Healthy carbs'];
      snackFoods = ['Nuts', 'Fruit', 'Yogurt'];
    }

    return [
      _meal('Breakfast', breakfastFoods, breakfast),
      _meal('Lunch', lunchFoods, lunch),
      _meal('Dinner', dinnerFoods, dinner),
      _meal('Snacks', snackFoods, snacks),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: !_hasProfile
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No profile found.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Please fill your data in the Me page.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Your Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        Text('Name: ${_userName ?? ''}'),
                        Text('Weight: ${(_weight ?? 0).toStringAsFixed(1)} kg'),
                        Text('Height: ${(_height ?? 0).toStringAsFixed(0)} cm'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('BMI: $_bmiText'),
                            if (_bmiCategory.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _bmiCategoryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _bmiCategory,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: _bmiCategoryColor),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'Workout', child: Text('Workout Recommendations')),
                      DropdownMenuItem(value: 'Food', child: Text('Food Recommendations')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _type = value;
                        // Ensure goal is valid for the selected type
                        if (_type == 'Food' && _goal == 'General Fitness') {
                          _goal = 'Lose Weight';
                        }
                        if (_type == 'Workout' && _goal == 'Maintain') {
                          _goal = 'Lose Weight';
                        }
                      });
                      _generate();
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _goal,
                    decoration: InputDecoration(labelText: _type == 'Workout' ? 'Goal' : 'Food Goal'),
                    items: _type == 'Workout'
                        ? const [
                            DropdownMenuItem(value: 'Lose Weight', child: Text('Lose Weight')),
                            DropdownMenuItem(value: 'Build Muscle', child: Text('Build Muscle')),
                            DropdownMenuItem(value: 'General Fitness', child: Text('General Fitness')),
                          ]
                        : const [
                            DropdownMenuItem(value: 'Lose Weight', child: Text('Lose Weight')),
                            DropdownMenuItem(value: 'Build Muscle', child: Text('Build Muscle')),
                            DropdownMenuItem(value: 'Maintain', child: Text('Maintain / Healthy')),
                          ],
                    onChanged: (value) {
                      setState(() => _goal = value);
                      _generate();
                    },
                  ),

                  if (_type == 'Food') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _activity,
                      decoration: const InputDecoration(labelText: 'Activity Level'),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low (little exercise)')),
                        DropdownMenuItem(value: 'Medium', child: Text('Medium (3-4 days/week)')),
                        DropdownMenuItem(value: 'High', child: Text('High (5+ days/week)')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _activity = value);
                        _generate();
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  if (_type == 'Workout' && _workoutRecs.isNotEmpty) ...[
                    const Text(
                      'Recommended Workouts',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._workoutRecs.map((rec) {
                      final items = (rec['items'] as List<String>);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['title'] as String,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(rec['description'] as String),
                            const SizedBox(height: 6),
                            ...items.map((item) => Text('• $item')),
                            const Divider(height: 20),
                          ],
                        ),
                      );
                    }),
                  ],

                  if (_type == 'Food' && _dailyTargetKcal != null && _mealPlan.isNotEmpty) ...[
                    Text(
                      'Daily Target: $_dailyTargetKcal kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Meal Plan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._mealPlan.map((meal) {
                      final items = (meal['items'] as List<Map<String, dynamic>>);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${meal['title']} (${meal['totalKcal']} kcal)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            ...items.map((it) => Text('• ${it['name']} - ${it['kcal']} kcal')),
                            const Divider(height: 20),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
      ),
    );
  }
}
