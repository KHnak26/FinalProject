import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../data/data_service.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = DataService();
  String? _exerciseType;
  final TextEditingController _durationCtl = TextEditingController();
  String? _intensity;
  List<ExerciseModel> _savedExercises = [];

  @override
  void dispose() {
    _durationCtl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadLastSaved();
  }

  Future<void> _loadLastSaved() async {
    final exercises = await _dataService.loadExercises();
    if (!mounted) return;
    setState(() => _savedExercises = exercises);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final duration = int.tryParse(_durationCtl.text.trim());
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for duration')),
      );
      return;
    }

    final newExercise = ExerciseModel(
      exerciseType: _exerciseType!,
      duration: duration,
      intensity: _intensity!,
      savedAt: DateTime.now(),
    );

    final success = await _dataService.addExercise(newExercise);

    if (!mounted) return;
    if (success) {
      await _loadLastSaved();
      if (!mounted) return;
      setState(() {
        _exerciseType = null;
        _durationCtl.clear();
        _intensity = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Exercise saved')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✗ Failed to save exercise')));
    }
  }

  Future<void> _deleteExercise(int index) async {
    final success = await _dataService.deleteExercise(index);
    if (success) await _loadLastSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Exercise'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Log Exercise',
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
                    children: [
                      DropdownButtonFormField<String>(
                        value: _exerciseType,
                        items: const [
                          DropdownMenuItem(value: 'Running', child: Text('Running')),
                          DropdownMenuItem(value: 'Walking', child: Text('Walking')),
                          DropdownMenuItem(value: 'Cycling', child: Text('Cycling')),
                          DropdownMenuItem(value: 'Swimming', child: Text('Swimming')),
                          DropdownMenuItem(value: 'Gym', child: Text('Gym')),
                        ],
                        onChanged: (v) => setState(() => _exerciseType = v),
                        decoration: const InputDecoration(labelText: 'Exercise Type'),
                        validator: (v) => (v == null) ? 'Select an exercise type' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _durationCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty) return 'Enter duration';
                          final n = int.tryParse(text);
                          if (n == null || n <= 0) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _intensity,
                        items: const [
                          DropdownMenuItem(value: 'Light', child: Text('Light')),
                          DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                        ],
                        onChanged: (v) => setState(() => _intensity = v),
                        decoration: const InputDecoration(labelText: 'Intensity'),
                        validator: (v) => (v == null) ? 'Select intensity' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saved Exercises',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_savedExercises.isEmpty)
                  const Text('No exercises saved yet.')
                else
                  ..._savedExercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${exercise.exerciseType} - ${exercise.duration} min'),
                      subtitle: Text(exercise.intensity),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExercise(index),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
