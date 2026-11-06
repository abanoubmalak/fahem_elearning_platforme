import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String _selectedStage = 'الصف الأول الإعدادي';
  String _selectedSemester = 'الترم الثاني';
  bool _isInitialized = false;

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final List<String> _stages = [
    'الصف الأول الابتدائي',
    'الصف الثاني الابتدائي',
    'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي',
    'الصف الخامس الابتدائي',
    'الصف السادس الابتدائي',
    'الصف الأول الإعدادي',
    'الصف الثاني الإعدادي',
    'الصف الثالث الإعدادي',
  ];

  final List<String> _semesters = ['الترم الأول', 'الترم الثاني'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
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
    if (_nameController.text.trim().isEmpty) {
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

    String oldPass = _oldPasswordController.text;
    String newPass = _newPasswordController.text;
    String confPass = _confirmPasswordController.text;

    if (oldPass.isNotEmpty || newPass.isNotEmpty || confPass.isNotEmpty) {
      if (oldPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى إدخال كلمة المرور الحالية لتتمكن من تغييرها.',
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
              'خطأ: كلمة المرور الجديدة وتأكيدها غير متطابقين!',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    context.read<StudentCubit>().updateStudentProfile(
      newName: _nameController.text,
      newGrade: _selectedStage,
      newTerm: _selectedSemester,
      oldPassword: (oldPass.isNotEmpty && newPass.isNotEmpty) ? oldPass : null,
      newPassword: (oldPass.isNotEmpty && newPass.isNotEmpty) ? newPass : null,
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج من الحساب؟',
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
              onPressed: () {
                Navigator.pop(ctx);
                context.read<StudentCubit>().signOutUser();
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تعديل ملفك الدراسي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),

        body: BlocConsumer<StudentCubit, StudentState>(
          listener: (context, state) {
            if (state is StudentUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم حفظ وتحديث التعديلات الجديدة بنجاح 🎉',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Color(0xFF005F61),
                ),
              );
              Navigator.pop(context);
            }

            if (state is StudentLoggedOut) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                (route) => false,
              );
            }

            if (state is StudentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is StudentLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF005F61)),
              );
            }

            if (state is StudentLoaded) {
              if (!_isInitialized) {
                _nameController.text = state.name;
                _emailController.text = state.email;
                _selectedStage = _stages.contains(state.grade)
                    ? state.grade
                    : _stages.first;
                _selectedSemester = _semesters.contains(state.term)
                    ? state.term
                    : _semesters.first;
                _isInitialized = true;
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.08 * 255).toInt(),
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 46,
                            backgroundColor: Color(0xFFEDF7F7),
                            child: Icon(
                              Icons.school_rounded,
                              size: 48,
                              color: Color(0xFF005F61),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          left: 2,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Color(0xFFE6A100),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _buildSectionTitle('البيانات الشخصية والهوية'),
                    _buildCardContainer(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'الاسم كامل',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني (لا يمكن تعديله)',
                            icon: Icons.alternate_email_rounded,
                            enabled: false,
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle('إعدادات الأمان'),
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
                              onPressed: () =>
                                  setState(() => _obscureOld = !_obscureOld),
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
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'تأكيد كلمة المرور',
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
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle('السنة الدراسية والترم'),
                    _buildCardContainer(
                      child: Column(
                        children: [
                          _buildDropdownField(
                            label: 'الصف الدراسي الحالي',
                            value: _selectedStage,
                            items: _stages,
                            onChanged: (val) =>
                                setState(() => _selectedStage = val!),
                          ),
                          const SizedBox(height: 15),
                          _buildDropdownField(
                            label: 'الفصل الدراسي',
                            value: _selectedSemester,
                            items: _semesters,
                            icon: Icons.calendar_today_outlined,
                            onChanged: (val) =>
                                setState(() => _selectedSemester = val!),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle('ربط حساب ولي الأمر'),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF6E5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(
                            0xFFE6A100,
                          ).withAlpha((0.3 * 255).toInt()),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.vpn_key_outlined,
                            color: Color(0xFFE6A100),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'كود ربط حساب الأب',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  state.linkingCode,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: Color(0xFFE6A100),
                              size: 20,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: state.linkingCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تم نسخ الكود بنجاح',
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                ),
                              );
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
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveProfileData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F61),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'حفظ التعديلات الجديدة',
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
                                color: Colors.redAccent,
                                size: 20,
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
                                side: const BorderSide(color: Colors.redAccent),
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
              );
            }
            return const SizedBox();
          },
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
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
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
        color: enabled ? AppColors.textMain : Colors.grey[600],
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData icon = Icons.school_outlined,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      items: items
          .map(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.grey,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF005F61), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF005F61)),
        ),
      ),
    );
  }
}
