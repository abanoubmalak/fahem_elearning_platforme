// lib/features/parent/presentation/screens/parent_profile_screen.dart
import 'package:fahem/core/routing/routes.dart'; 
import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadParentProfileData(); 
  }

  void _loadParentProfileData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _emailController.text = currentUser.email ?? '';
        
        DocumentSnapshot parentDoc = await FirebaseFirestore.instance
            .collection('parents')
            .doc(currentUser.uid)
            .get();

        if (parentDoc.exists && parentDoc.data() != null && mounted) {
          setState(() {
            _nameController.text = parentDoc['name'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل ملف ولي الأمر: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 💎 دالة حفظ التعديلات الذكية المحدثة لترجمة الأخطاء والتوجيه التلقائي
  void _saveProfileData() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: الاسم لا يمكن أن يكون فارغاً!', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent)
      );
      return;
    }

    String oldPass = _oldPasswordController.text;
    String newPass = _newPasswordController.text;
    String confPass = _confirmPasswordController.text;

    if (oldPass.isNotEmpty || newPass.isNotEmpty || confPass.isNotEmpty) {
      if (oldPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال كلمة المرور الحالية أولاً.', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
        return;
      }
      if (newPass.isEmpty || newPass.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور الجديدة يجب أن لا تقل عن 6 أحرف.', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
        return;
      }
      if (newPass != confPass) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ: كلمة المرور غير متطابقة!', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
        return;
      }
    }

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 1. تحديث الاسم في الفايرستور
      await FirebaseFirestore.instance.collection('parents').doc(currentUser.uid).update({
        'name': _nameController.text.trim(),
      });

      // 2. تحديث الباسورد في الـ Authentication لو تم إدخاله مع التقاط الأخطاء يدوياً
      if (newPass.isNotEmpty && oldPass.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: oldPass);
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPass.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث بيانات ولي الأمر بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF005F61)));
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        context.read<ParentCubit>().loadParentDashboard(); 

        // ↩️ التوجيه المباشر الفوري للشاشة الرئيسية لولي الأمر بعد التحديث المستقر
        Navigator.pushNamedAndRemoveUntil(context, Routes.ParentWrapper, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      // 💎 فحص وترجمة كود خطأ كلمة المرور الحالية غير الصحيحة
      String friendlyMessage = 'حدث خطأ أثناء حفظ التعديلات الرقمية.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        friendlyMessage = 'كلمة المرور الحالية التي أدخلتها غير صحيحة ❌';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyMessage, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج من الحساب؟', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
                }
              },
              child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentCubit, ParentState>(
      builder: (context, state) {
        final linkedChildrenCount = state.children.length; 

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 70,
              flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF005F61), Color(0xFF003D3F)]))),
              title: const Text('الحساب الشخصي لولي الأمر', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.08 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 5))]),
                    child: const CircleAvatar(radius: 46, backgroundColor: Color(0xFFFEF6E5), child: Icon(Icons.supervisor_account_rounded, size: 48, color: Color(0xFFE6A100))),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionTitle('إحصائيات العائلة'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFEDF7F7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF005F61).withAlpha((0.15 * 255).toInt()))),
                    child: Row(
                      children: [
                        const Icon(Icons.people_alt_outlined, color: Color(0xFF005F61), size: 22),
                        const SizedBox(width: 14),
                        const Expanded(child: Text('عدد الأبناء المربوطين بالحساب:', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)))),
                        Text('$linkedChildrenCount', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF005F61))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle('البيانات الأساسية'),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildTextField(controller: _nameController, label: 'الاسم كامل', icon: Icons.person_outline_rounded),
                        const SizedBox(height: 15),
                        _buildTextField(controller: _emailController, label: 'البريد الإلكتروني الحالي', icon: Icons.alternate_email_rounded, enabled: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle('إعدادات الأمان (كلمة المرور)'),
                  _buildCardContainer(
                    child: Column(
                      children: [
                        _buildTextField(controller: _oldPasswordController, label: 'كلمة المرور الحالية', icon: Icons.lock_open_rounded, isPassword: true, obscureText: _obscureOld, suffixIcon: IconButton(icon: Icon(_obscureOld ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20), onPressed: () => setState(() => _obscureOld = !_obscureOld))),
                        const SizedBox(height: 15),
                        _buildTextField(controller: _newPasswordController, label: 'كلمة المرور الجديدة', icon: Icons.lock_outline_rounded, isPassword: true, obscureText: _obscureNew, suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20), onPressed: () => setState(() => _obscureNew = !_obscureNew))),
                        const SizedBox(height: 15),
                        _buildTextField(controller: _confirmPasswordController, label: 'تأكيد كلمة المرور الجديدة', icon: Icons.gpp_good_outlined, isPassword: true, obscureText: _obscureConfirm, suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _saveProfileData, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: const Text('حفظ التعديلات الشخصية', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)))),
                        const SizedBox(height: 16),
                        SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent), label: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 28.0), child: Align(alignment: Alignment.centerRight, child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey))));
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]), child: child);
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, bool obscureText = false, Widget? suffixIcon, bool enabled = true}) {
    return TextField(
      controller: controller, obscureText: obscureText, enabled: enabled,
      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: enabled ? const Color(0xFF1F2937) : Colors.grey[600], fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: enabled ? const Color(0xFF005F61) : Colors.grey, size: 20),
        suffixIcon: suffixIcon, filled: true, fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey[100],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.2)),
      ),
    );
  }
}