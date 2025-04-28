import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FamilyMember {
  String name;
  String? photoPath;

  FamilyMember({required this.name, this.photoPath});

  Map<String, dynamic> toJson() => {
    'name': name,
    'photoPath': photoPath,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    name: json['name'],
    photoPath: json['photoPath'],
  );
}

class PatientInfoPage extends StatefulWidget {
  const PatientInfoPage({super.key});

  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tasksController = TextEditingController();
  final _medicationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _dietaryNeedsController = TextEditingController();
  List<FamilyMember> _familyMembers = [];
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
      _tasksController.text = prefs.getString('patient_tasks') ?? '';
      _medicationController.text = prefs.getString('patient_medication') ?? '';
      _emergencyContactController.text = prefs.getString('emergency_contact') ?? '';
      _medicalConditionsController.text = prefs.getString('medical_conditions') ?? '';
      _dietaryNeedsController.text = prefs.getString('dietary_needs') ?? '';
      final familyJson = prefs.getString('patient_family');
      if (familyJson != null && familyJson.isNotEmpty) {
        try {
          final List<dynamic> familyList = jsonDecode(familyJson);
          _familyMembers = familyList.map((e) => FamilyMember.fromJson(e)).toList();
        } catch (e) {
          // Handle legacy data (non-JSON string)
          try {
            // Attempt to migrate comma-separated family members
            final legacyFamily = familyJson.split('،').map((name) => name.trim()).where((name) => name.isNotEmpty).toList();
            _familyMembers = legacyFamily.map((name) => FamilyMember(name: name, photoPath: null)).toList();
            // Save migrated data in the new JSON format
            prefs.setString('patient_family', jsonEncode(_familyMembers.map((e) => e.toJson()).toList()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحويل بيانات أفراد العائلة القديمة. الرجاء إضافة صور.'),
                backgroundColor: Colors.orange,
              ),
            );
          } catch (migrationError) {
            // If migration fails, clear the invalid data
            _familyMembers = [];
            prefs.remove('patient_family');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('خطأ في بيانات أفراد العائلة. الرجاء إدخالها من جديد.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('patient_name', _nameController.text);
      await prefs.setString('patient_tasks', _tasksController.text);
      await prefs.setString('patient_medication', _medicationController.text);
      await prefs.setString('emergency_contact', _emergencyContactController.text);
      await prefs.setString('medical_conditions', _medicalConditionsController.text);
      await prefs.setString('dietary_needs', _dietaryNeedsController.text);
      await prefs.setString(
          'patient_family', jsonEncode(_familyMembers.map((e) => e.toJson()).toList()));
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

  Future<void> _addFamilyMember() async {
    final nameController = TextEditingController();
    XFile? pickedImage;
    bool isSaving = false;

    // Request storage or media permission
    PermissionStatus status;
    if (Platform.isAndroid && await _isAndroid13OrAbove()) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Please allow access to photos.'),
        ),
      );
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Family Member Name',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF723D92)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                  final picker = ImagePicker();
                  try {
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() {
                        pickedImage = image;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error picking image: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF723D92),
                  foregroundColor: Colors.white,
                ),
                child: Text(pickedImage == null ? 'Pick Photo' : 'Photo Selected'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSaving
                  ? null
                  : () {
                if (nameController.text.isNotEmpty && pickedImage != null) {
                  setDialogState(() => isSaving = true);
                  setState(() {
                    _familyMembers.add(FamilyMember(
                      name: nameController.text,
                      photoPath: pickedImage!.path,
                    ));
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please provide both name and photo')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Family Members',
                          style: TextStyle(
                            color: Color(0xFF723D92),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._familyMembers.map((member) => ListTile(
                          leading: member.photoPath != null
                              ? Image.file(
                            File(member.photoPath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                          )
                              : const Icon(Icons.person, size: 50),
                          title: Text(member.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _familyMembers.remove(member);
                              });
                            },
                          ),
                        )),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _addFamilyMember,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF723D92),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add Family Member'),
                        ),
                      ],
                    ),
                  ),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isSaving ? 60 : constraints.maxWidth,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF723D92),
                            Color(0xFF9B59B6),
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
                    );
                  },
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