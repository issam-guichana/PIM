import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInfoPage extends StatefulWidget {
  const PatientInfoPage({super.key});

  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familyController = TextEditingController();
  final _tasksController = TextEditingController();
  final _medicationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _dietaryNeedsController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('patient_name') ?? '';
      _familyController.text = prefs.getString('patient_family') ?? '';
      _tasksController.text = prefs.getString('patient_tasks') ?? '';
      _medicationController.text = prefs.getString('patient_medication') ?? '';
      _emergencyContactController.text = prefs.getString('emergency_contact') ?? '';
      _medicalConditionsController.text = prefs.getString('medical_conditions') ?? '';
      _dietaryNeedsController.text = prefs.getString('dietary_needs') ?? '';
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('patient_name', _nameController.text);
      await prefs.setString('patient_family', _familyController.text);
      await prefs.setString('patient_tasks', _tasksController.text);
      await prefs.setString('patient_medication', _medicationController.text);
      await prefs.setString('emergency_contact', _emergencyContactController.text);
      await prefs.setString('medical_conditions', _medicalConditionsController.text);
      await prefs.setString('dietary_needs', _dietaryNeedsController.text);
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ المعلومات بنجاح'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _tasksController.dispose();
    _medicationController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _dietaryNeedsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF723D92),
        elevation: 0,
        title: const Text(
          'Patient Information',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تعليمات'),
                  content: const Text(
                    'أدخل معلومات المريض بدقة. هذه المعلومات ستساعد المساعد الصوتي على تقديم دعم أفضل.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('حسنًا'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF723D92),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _nameController,
                  label: 'Patient Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المريض';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _familyController,
                  label: 'Family Members',
                  hint: 'مثال: عصام ولدي, ليلى بنتي',
                  icon: Icons.family_restroom,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _emergencyContactController,
                  label: 'Emergency Contact',
                  hint: 'مثال: عصام +21612345678',
                  icon: Icons.emergency,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال جهة اتصال الطوارئ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daily Needs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF723D92),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _tasksController,
                  label: 'Daily Tasks',
                  hint: 'مثال: فطور 8 صباحًا, نوم 10 بالليل',
                  icon: Icons.task,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _medicationController,
                  label: 'Medication Schedule',
                  hint: 'مثال: دواء القلب 9 صباحًا',
                  icon: Icons.medical_services,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _medicalConditionsController,
                  label: 'Medical Conditions',
                  hint: 'مثال: ألزهايمر, ضغط الدم',
                  icon: Icons.health_and_safety,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  controller: _dietaryNeedsController,
                  label: 'Dietary Needs',
                  hint: 'مثال: بدون سكر, قليل الملح',
                  icon: Icons.food_bank,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSaving ? 60 : double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF723D92),
                        const Color(0xFF9B59B6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                        : const Text(
                      'Save Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF723D92)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(
              color: Color(0xFF723D92),
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          validator: validator,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}