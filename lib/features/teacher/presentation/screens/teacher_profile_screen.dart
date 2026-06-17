// lib/features/teacher/presentation/screens/teacher_profile_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();

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
    _nameController = TextEditingController(text: 'أبانوب ملاك');
    _emailController = TextEditingController(text: 'abanoub.math@fahem.com');
    _specialtyController = TextEditingController(text: 'الرياضيات (معتمد من الإدارة)');
    _phoneController = TextEditingController(text: '01234567890');
    
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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

  void _saveProfileData() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث بيانات الأمان والتواصل بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فتح معرض الصور لاختيار صورة شخصية جديدة...', style: TextStyle(fontFamily: 'Cairo'))),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تسجيل الخروج من حساب المعلم...', style: TextStyle(fontFamily: 'Cairo'))),
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
            // 💎 نقلنا محتوى الشاشة ليكون أول عنصر في الـ Stack 💎
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: headerHeight -20),

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
            // 💎 نقلنا البانر ليكون آخر عنصر في الـ Stack ليطفو فوق المحتوى 💎
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-60,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight, end: Alignment.bottomLeft,
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                  ),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                ),
                child: SafeArea(
                  bottom: false,
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