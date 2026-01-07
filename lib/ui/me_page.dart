import 'package:flutter/material.dart';
import '../data/data_service.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = DataService();
  final TextEditingController _nameCtl = TextEditingController();
  String _sex = 'Male';
  DateTime? _dob;
  final TextEditingController _weightCtl = TextEditingController();
  final TextEditingController _heightCtl = TextEditingController();

  @override
  void dispose() {
    _nameCtl.dispose();
    _weightCtl.dispose();
    _heightCtl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _dataService.loadProfile();
    if (!mounted) return;
    setState(() {
      _nameCtl.text = (data['name'] as String?) ?? '';
      _sex = (data['sex'] as String?) ?? 'Male';
      _dob = data['dob'] as DateTime?;
      final w = data['weightKg'] as double?;
      final h = data['heightCm'] as double?;
      _weightCtl.text = (w != null && w > 0) ? w.toStringAsFixed(1) : '';
      _heightCtl.text = (h != null && h > 0) ? h.toStringAsFixed(0) : '';
    });
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final weight = double.tryParse(_weightCtl.text.trim());
    final height = double.tryParse(_heightCtl.text.trim());
    if (weight == null || weight <= 0 || height == null || height <= 0) return;
    if (_dob == null) return;

    await _dataService.saveProfile(
      name: _nameCtl.text.trim(),
      sex: _sex,
      dob: _dob!,
      weightKg: weight,
      heightCm: height,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Me'),
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
                  'Profile',
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
                      TextFormField(
                        controller: _nameCtl,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _sex,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _sex = v ?? 'Male'),
                        decoration: const InputDecoration(labelText: 'Sex'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: _dob == null ? 'Select date' : _dob!.toLocal().toString().split(' ')[0],
                        ),
                        onTap: _pickDob,
                        validator: (_) => _dob == null ? 'Select DOB' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _weightCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight (kg)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter weight' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _heightCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (cm)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter height' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _save, child: const Text('Save Profile')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
