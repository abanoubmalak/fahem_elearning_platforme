// lib/features/admin/presentation/screens/students/edit_student_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';

class EditStudentScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const EditStudentScreen({super.key, required this.studentData});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _selectedStage;

  final List<String> _stages = [
    'الصف الأول الابتدائي', 'الصف الثاني الابتدائي', 'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي', 'الصف الخامس الابتدائي', 'الصف السادس الابتدائي',
    'الصف الأول الإعدادي', 'الصف الثاني الإعدادي', 'الصف الثالث الإعدادي',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentData['name'] ?? '');
    _emailController = TextEditingController(text: widget.studentData['email'] ?? '');
    _selectedStage = widget.studentData['stage'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStage == null) {
      return;
    }

    final updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'stage': _selectedStage,
    };

    final error = await context.read<AdminCubit>().updateStudentData(
      studentId: widget.studentData['id'],
      studentData: updatedData,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث البيانات بنجاح!'), backgroundColor: Color(0xFF005F61)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.16;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(label: 'اسم الطالب', controller: _nameController, icon: Icons.person_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'البريد الإلكتروني', controller: _emailController, icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                     
                      
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save_rounded, color: Colors.white),
                          label: const Text('حفظ التعديلات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildHeader(headerHeight),
          ],
        ),
      ),
    );
  }

  // ── Widgets مساعدة ──
  Widget _buildHeader(double height) => Positioned(
    top: 0, left: 0, right: 0, height: height,
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            const Text('تعديل بيانات الطالب', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    ),
  );

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
    prefixIcon: Icon(icon, color: const Color(0xFF005F61)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 2)),
  );

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val!.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }
}