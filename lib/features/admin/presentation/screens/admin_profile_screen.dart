import 'package:fahem/core/routing/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _userDocId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadAdminProfileData();
  }

  Future<void> _loadAdminProfileData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      setState(() {
        _isLoading = true;
        _emailController.text = currentUser.email ?? '';
      });

      final firestore = FirebaseFirestore.instance;

      final doc = await firestore.collection('users').doc(currentUser.uid).get();

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        setState(() {
          _userDocId = doc.id;
          _nameController.text =
              (data['name']?.toString().trim().isNotEmpty ?? false)
                  ? data['name'].toString()
                  : (currentUser.displayName ?? 'مدير المنظومة');

          _emailController.text =
              (data['email']?.toString().trim().isNotEmpty ?? false)
                  ? data['email'].toString()
                  : (currentUser.email ?? '');
        });
      } else {
        setState(() {
          _userDocId = currentUser.uid;
          _nameController.text = currentUser.displayName ?? 'مدير المنظومة';
          _emailController.text = currentUser.email ?? '';
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل ملف الإدارة: $e');
      if (mounted) {
        setState(() {
          _nameController.text = 'مدير المنظومة';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    final name = _nameController.text.trim();
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confPass = _confirmPasswordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'خطأ: الاسم لا يمكن أن يكون فارغاً!',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (oldPass.isNotEmpty || newPass.isNotEmpty || confPass.isNotEmpty) {
      if (oldPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى إدخال كلمة المرور الحالية أولاً.',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (newPass.isEmpty || newPass.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'كلمة المرور الجديدة يجب أن لا تقل عن 6 أحرف.',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (newPass != confPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'خطأ: كلمة المرور غير متطابقة!',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      setState(() => _isLoading = true);

      final firestore = FirebaseFirestore.instance;
      final targetDocId = _userDocId ?? currentUser.uid;

      await firestore.collection('users').doc(targetDocId).set({
        'name': name,
        'uid': currentUser.uid,
        'email': currentUser.email,
        'role': 'admin',
      }, SetOptions(merge: true));

      await currentUser.updateDisplayName(name);

      if (newPass.isNotEmpty && oldPass.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: oldPass,
        );

        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPass);
      }

      if (!mounted) return;

      setState(() {
        _userDocId = targetDocId;
      });

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث بيانات الإدارة بنجاح 🎉',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Color(0xFF005F61),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String friendlyMessage = 'حدث خطأ أثناء حفظ التعديلات.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        friendlyMessage = 'كلمة المرور الحالية التي أدخلتها غير صحيحة ❌';
      } else if (e.code == 'requires-recent-login') {
        friendlyMessage = 'يجب تسجيل الدخول مرة أخرى قبل تغيير كلمة المرور.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              friendlyMessage,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل الحفظ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج من حساب الإدارة؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.loginScreen,
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'خروج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)],
              ),
            ),
          ),
          title: const Text(
            'الحساب الشخصي للإدارة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF005F61)),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.08 * 255).toInt()),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 46,
                        backgroundColor: Color(0xFFEDF7F7),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 48,
                          color: Color(0xFF005F61),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildSectionTitle('البيانات الأساسية'),
                    _buildCardContainer(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'اسم المسؤول',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني للإدارة',
                            icon: Icons.alternate_email_rounded,
                            enabled: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
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
                              icon: Icon(
                                _obscureOld
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
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
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
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
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
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
                                backgroundColor: const Color(0xFF005F61),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'حفظ التعديلات الشخصية',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                'تسجيل الخروج',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: enabled ? const Color(0xFF1F2937) : Colors.grey[600],
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF005F61) : Colors.grey,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.2),
        ),
      ),
    );
  }
}