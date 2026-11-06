import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';

class EditParentScreen extends StatefulWidget {
  final Map<String, dynamic> parentData;
  const EditParentScreen({super.key, required this.parentData});

  @override
  State<EditParentScreen> createState() => _EditParentScreenState();
}

class _EditParentScreenState extends State<EditParentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parentData['name'] ?? '');
    _emailController = TextEditingController(text: widget.parentData['email'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
    };

    final error = await context.read<AdminCubit>().updateParentData(
      parentId: widget.parentData['id'],
      parentData: updatedData,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.pop(context, {
        ...widget.parentData,
        ...updatedData,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث بيانات ولي الأمر بنجاح!', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF27AE60)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
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
                      _buildTextField(label: 'اسم ولي الأمر', controller: _nameController, icon: Icons.person_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'البريد الإلكتروني', controller: _emailController, icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save_rounded, color: Colors.white),
                          label: const Text('حفظ التعديلات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      const Text('تعديل بيانات ولي الأمر', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller, keyboardType: keyboardType, style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13), prefixIcon: Icon(icon, color: const Color(0xFF27AE60)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27AE60), width: 2))),
      validator: (val) => val!.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }
}