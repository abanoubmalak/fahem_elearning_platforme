// lib/features/teacher/presentation/screens/teacher_profile_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart'; // 👈 استيراد راوتر التطبيق بالتوازي
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 استيراد الأوث للتعامل مع الحساب
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 استيراد الفايرستور لجلب وتحديث البيانات

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // متحكمات الحقول الموصولة بالداتابيز حياً
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  
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
    _specialtyController = TextEditingController();
    _phoneController = TextEditingController();
    
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _loadTeacherProfileData(); // 👈 جلب بيانات تخصص وتواصل المعلم حياً من الفايربيز
  }

  // 💎 دالة جلب وقراءة بيانات المعلم الحالية من قاعدة البيانات السحابية حياً
  void _loadTeacherProfileData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _emailController.text = currentUser.email ?? '';
        
        DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
            .collection('teachers')
            .doc(currentUser.uid)
            .get();

        if (teacherDoc.exists && teacherDoc.data() != null && mounted) {
          final data = teacherDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? 'معلم فاهم';
            _specialtyController.text = data['specialty'] ?? 'غير محدد';
            _phoneController.text = data['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل ملف المعلم: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 💎 دالة حفظ تعديلات التواصل والأمان وتوطين الأخطاء والتوجيه المباشر
  void _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;

    String oldPass = _oldPasswordController.text;
    String newPass = _newPasswordController.text;

    // التحقق الاستباقي لو أراد المعلم تغيير الباسورد
    if (oldPass.isNotEmpty || newPass.isNotEmpty) {
      if (oldPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال كلمة المرور الحالية أولاً.', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
        return;
      }
      if (newPass.isEmpty || newPass.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور الجديدة يجب أن لا تقل عن 6 أحرف.', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
        return;
      }
    }

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 1. تحديث رقم الهاتف للتواصل المباشر في الفايرستور
      await FirebaseFirestore.instance.collection('teachers').doc(currentUser.uid).update({
        'phone': _phoneController.text.trim(),
      });

      // 2. تحديث الباسورد في الـ Authentication لو تم إدخاله
      if (newPass.isNotEmpty && oldPass.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: oldPass);
        await currentUser.reauthenticateWithCredential(credential); // إعادة المصادقة للتأكد من هويته
        await currentUser.updatePassword(newPass.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات الأمان والتواصل بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF005F61)),
        );

        // ↩️ التوجيه التلقائي الفوري للشاشة الرئيسية للمعلم بعد التحديث المستقر
        Navigator.pushNamedAndRemoveUntil(context, Routes.TeacherMainWrapper, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      // 💎 التقاط وترجمة خطأ كلمة المرور الحالية لمنع الأكواد المزعجة أمام اللجنة
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

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فتح معرض الصور لاختيار صورة شخصية جديدة...', style: TextStyle(fontFamily: 'Cairo'))),
    );
  }

  // 💎 دالة تسجيل الخروج الرسمية وتطهير الجلسة
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: dialogContext(ctx),
      ),
    );
  }

  Widget dialogContext(BuildContext ctx) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
      content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج من حساب المعلم؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseAuth.instance.signOut(); // إنهاء الجلسة سحابياً
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
            }
          },
          child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      resizeToAvoidBottomInset: true,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. جسم الشاشة (في الخلفية أولاً) ====================
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: headerHeight - 20),

                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.08 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 5))],
                            ),
                            child: const CircleAvatar(
                              radius: 46,
                              backgroundColor: Color(0xFFFEF6E5),
                              child: Icon(Icons.school_rounded, size: 48, color: Color(0xFFE6A100)),
                            ),
                          ),
                          GestureDetector(
                            onTap: _changeProfilePicture,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF005F61), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Text('مرحباً بك يا أستاذ', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)),
                      Text(_nameController.text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                      
                      const SizedBox(height: 25),

                      _buildSectionTitle('البيانات الأساسية (معتمدة من الإدارة)'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.commonShadow),
                        child: Column(
                          children: [
                            _buildTextField(controller: _nameController, label: 'الاسم كامل', icon: Icons.person_outline_rounded, enabled: false),
                            const SizedBox(height: 15),
                            _buildTextField(controller: _emailController, label: 'البريد الإلكتروني المؤسسي', icon: Icons.alternate_email_rounded, enabled: false),
                            const SizedBox(height: 15),
                            _buildTextField(controller: _specialtyController, label: 'مادة التخصص', icon: Icons.workspace_premium_rounded, enabled: false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildSectionTitle('بيانات التواصل'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.commonShadow),
                        child: _buildTextField(
                          controller: _phoneController, 
                          label: 'رقم الهاتف للتواصل المباشر', 
                          icon: Icons.phone_android_rounded, 
                          isPhone: true,
                          validator: (val) => val!.isEmpty ? 'لا يمكن ترك رقم الهاتف فارغاً' : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildSectionTitle('تغيير كلمة المرور الأمان'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.commonShadow),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _oldPasswordController,
                              label: 'كلمة المرور الحالية',
                              icon: Icons.lock_open_rounded,
                              obscureText: _obscureOld,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureOld ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _obscureOld = !_obscureOld),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _newPasswordController,
                              label: 'كلمة المرور الجديدة',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureNew,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                              validator: (val) {
                                if (val!.isNotEmpty && val.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور الجديدة',
                              icon: Icons.gpp_good_outlined,
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              validator: (val) {
                                if (_newPasswordController.text.isNotEmpty && val != _newPasswordController.text) {
                                  return 'كلمتا المرور غير متطابقتين!';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity, height: 48,
                              child: ElevatedButton(
                                onPressed: _saveProfileData,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                                child: const Text('حفظ التعديلات والتحديث', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity, height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                                label: const Text('تسجيل الخروج من المنصة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),

            // ==================== 2. البانر الفيروزي العلوي (في المقدمة آخراً) ====================
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight - 60,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight, end: Alignment.bottomLeft,
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context), 
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'الحساب الشخصي للمعلم',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true,
    bool isPhone = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled, 
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: validator,
      style: TextStyle(
        fontFamily: isPhone || obscureText || !enabled ? 'Montserrat' : 'Cairo',
        fontSize: 13.5, 
        color: enabled ? AppColors.textMain : Colors.grey[600], 
        fontWeight: FontWeight.bold
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: enabled ? const Color(0xFF005F61) : Colors.grey, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey[100],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }
}