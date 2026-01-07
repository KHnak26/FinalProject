import 'package:flutter/material.dart';
import 'food_page.dart';
import 'exercise_page.dart';
import 'daily_count_page.dart';
import 'me_page.dart';
import 'recommendations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _labels = ['Food', 'Exercise', 'Daily Count'];
  final List<IconData> _icons = [Icons.restaurant, Icons.fitness_center, Icons.format_list_numbered];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitnessX'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildBox(0),
            const SizedBox(height: 10),
            _buildBox(1),
            const SizedBox(height: 10),
            _buildBox(2),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecommendationsPage()),
              ),
              child: const Text('Get Recommendations'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange,
        child: SizedBox(
          height: 56,
          child: Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MePage()),
              ),
              icon: const Icon(Icons.person, color: Colors.white),
              label: const Text('Me', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int index) {
    return InkWell(
      key: ValueKey('box$index'),
      onTap: () {
        if (index == 0) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodPage()));
        } else if (index == 1) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExercisePage()));
        } else if (index == 2) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyCountPage()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(_icons[index]),
            const SizedBox(width: 12),
            Text(
              _labels[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
