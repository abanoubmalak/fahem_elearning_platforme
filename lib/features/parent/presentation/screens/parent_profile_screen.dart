// lib/features/parent/presentation/screens/parent_profile_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  // الكنترولرز للبيانات النصية الخاصة بولي الأمر
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  // متغيرات حالة كلمات المرور
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // إحصائية سريعة
  final int _linkedChildrenCount = 2;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'أبانوب ملاك (ولي الأمر)');
    _emailController = TextEditingController(text: 'abanoub.parent@science.com');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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

  void _saveProfileData() {
    if (_newPasswordController.text.isNotEmpty && 
        _newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: كلمة المرور الجديدة غير متطابقة!', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث بيانات ولي الأمر بنجاح', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Color(0xFF005F61), // اللون الفيروزي المميز
      ),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تسجيل الخروج من حساب ولي الأمر...', style: TextStyle(fontFamily: 'Cairo'))),
    );
    // Navigator.pushNamedAndRemoveUntil(context, Routes.LoginScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 1. الترويسة العلوية باستخدام AppBar ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70, // مساحة مريحة لاستيعاب العنوان
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)], // الفيروزي المميز
              ),
              //borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          //   onPressed: () => Navigator.pop(context),
          // ),
          title: const Text(
            'الحساب الشخصي لولي الأمر',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),

        // ==================== 2. جسم الشاشة القابل للتمرير ====================
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              // ==================== أفاتار החساب ====================
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha((0.08 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 5)),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 46,
                  backgroundColor: Color(0xFFFEF6E5), // لون ذهبي هادئ
                  child: Icon(Icons.supervisor_account_rounded, size: 48, color: Color(0xFFE6A100)),
                ),
              ),
              const SizedBox(height: 25),

              // ==================== 3. كارت الإحصائيات العائلية ====================
              _buildSectionTitle('إحصائيات العائلة'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F7), // خلفية فيروزية ناعمة جداً
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF005F61).withAlpha((0.15 * 255).toInt())),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, color: Color(0xFF005F61), size: 22),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'عدد الأبناء المربوطين بالحساب حالياً:',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                    ),
                    Text(
                      '$_linkedChildrenCount',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF005F61)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ==================== 4. كارت البيانات الشخصية ====================
              _buildSectionTitle('البيانات الأساسية'),
              _buildCardContainer(
                child: Column(
                  children: [
                    _buildTextField(controller: _nameController, label: 'الاسم كامل', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController, 
                      label: 'البريد الإلكتروني الحالي (لا يمكن تعديله)', 
                      icon: Icons.alternate_email_rounded,
                      enabled: false, 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ==================== 5. كارت إعدادات الأمان ====================
              _buildSectionTitle('إعدادات الأمان (كلمة المرور)'),
              _buildCardContainer(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _oldPasswordController,
                      label: 'كلمة المرور الحالية',
                      icon: Icons.lock_open_rounded,
                      isPassword: true,
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
                      isPassword: true,
                      obscureText: _obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور الجديدة',
                      icon: Icons.gpp_good_outlined,
                      isPassword: true,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ==================== 6. أزرار الإجراءات السفلية ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfileData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F61), // الزر الفيروزي الأساسي
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('حفظ التعديلات الشخصية', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                        label: const Text('تسجيل الخروج من الحساب', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // مسافة سفلية مريحة
            ],
          ),
        ),
      ),
    );
  }

  // ==================== الويدجتس المساعدة الموحدة ====================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Align(
        alignment: Alignment.centerRight, 
        child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, bool obscureText = false, Widget? suffixIcon, bool enabled = true}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled, 
      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: enabled ? AppColors.textMain : Colors.grey[600], fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: enabled ? const Color(0xFF005F61) : Colors.grey, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey[100], 
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.2)),
      ),
    );
  }
}