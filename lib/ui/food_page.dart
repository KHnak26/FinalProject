import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../data/data_service.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = DataService();
  String? _foodType;
  final TextEditingController _caloriesCtl = TextEditingController();
  final TextEditingController _timeCtl = TextEditingController();
  List<FoodModel> _savedFoods = [];

  @override
  void dispose() {
    _caloriesCtl.dispose();
    _timeCtl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadLastSaved();
  }

  Future<void> _loadLastSaved() async {
    final foods = await _dataService.loadFoods();
    if (!mounted) return;
    setState(() => _savedFoods = foods);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final newFood = FoodModel(
      foodType: _foodType!,
      calories: int.parse(_caloriesCtl.text.trim()),
      time: _timeCtl.text.trim(),
      savedAt: DateTime.now(),
    );
    
    final success = await _dataService.addFood(newFood);
    
    if (success) {
      await _loadLastSaved();
      if (!mounted) return;
      setState(() {
        _foodType = null;
        _caloriesCtl.clear();
        _timeCtl.clear();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Food saved')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✗ Failed to save food')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Food'),
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
                  'Log Food',
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
                        value: _foodType,
                        items: const [
                          DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                          DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                          DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                          DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                        ],
                        onChanged: (v) => setState(() => _foodType = v),
                        decoration: const InputDecoration(labelText: 'Food Type'),
                        validator: (v) => (v == null) ? 'Select a food type' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _caloriesCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Calories'),
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty) return 'Enter calories';
                          final n = int.tryParse(text);
                          if (n == null || n <= 0) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _timeCtl,
                        decoration: const InputDecoration(labelText: 'Time'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter time' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _save, child: const Text('Save')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saved Foods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_savedFoods.isEmpty)
                  const Text('No foods saved yet.')
                else
                  ..._savedFoods.asMap().entries.map((entry) {
                    final index = entry.key;
                    final food = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${food.foodType} - ${food.calories} kcal'),
                      subtitle: Text(food.time),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final success = await _dataService.deleteFood(index);
                          if (success) await _loadLastSaved();
                        },
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
