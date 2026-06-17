// lib/features/admin/presentation/screens/teachers/add_teacher_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  نموذج بيانات المادة المعيّنة
// ─────────────────────────────────────────────
class _AssignedSubject {
  final String subject;
  final String stage;
  final String term;

  _AssignedSubject({
    required this.subject,
    required this.stage,
    required this.term,
  });

  @override
  String toString() => '$subject - $stage - $term';

  // لمنع التكرار بنفس المجموعة الثلاثية
  bool matches(_AssignedSubject other) =>
      subject == other.subject && stage == other.stage && term == other.term;
}

// ─────────────────────────────────────────────
//  الشاشة الرئيسية
// ─────────────────────────────────────────────
class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──
  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController  = TextEditingController();

  // ── Password visibility ──
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  // ── Subject picker state ──
  String? _selectedSubject;
  String? _selectedStage;
  String? _selectedTerm;

  // ── Assigned subjects list ──
  final List<_AssignedSubject> _assignedSubjects = [];

  // ── Static data ──

  /// المواد المتاحة لكل صف
  static const Map<String, List<String>> _subjectsByStage = {
    'الصف الأول الابتدائي':   ['لغة عربية', 'لغة إنجليزية', 'رياضيات'],
    'الصف الثاني الابتدائي':  ['لغة عربية', 'لغة إنجليزية', 'رياضيات'],
    'الصف الثالث الابتدائي':  ['لغة عربية', 'لغة إنجليزية', 'رياضيات'],
    'الصف الرابع الابتدائي':  ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'علوم', 'دراسات اجتماعية'],
    'الصف الخامس الابتدائي': ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'علوم', 'دراسات اجتماعية'],
    'الصف السادس الابتدائي': ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'علوم', 'دراسات اجتماعية'],
    'الصف الأول الإعدادي':   ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'علوم', 'دراسات اجتماعية'],
    'الصف الثاني الإعدادي':  ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'علوم', 'دراسات اجتماعية'],
    'الصف الثالث الإعدادي':  ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'علوم', 'دراسات اجتماعية'],
  };

  /// المواد المتاحة بناءً على الصف المختار حالياً
  List<String> get _availableSubjects =>
      _selectedStage != null ? (_subjectsByStage[_selectedStage!] ?? []) : [];

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

  final List<String> _terms = ['الترم الأول', 'الترم الثاني'];

  // ─────────────────────────────────────────────
  //  Logic
  // ─────────────────────────────────────────────
  void _addSubject() {
    if (_selectedSubject == null ||
        _selectedStage == null ||
        _selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار المادة والمرحلة والترم أولاً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newEntry = _AssignedSubject(
      subject: _selectedSubject!,
      stage:   _selectedStage!,
      term:    _selectedTerm!,
    );

    final alreadyExists =
        _assignedSubjects.any((e) => e.matches(newEntry));

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'هذه المادة بنفس المرحلة والترم مضافة بالفعل',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _assignedSubjects.add(newEntry);
      _selectedSubject = null;
      _selectedStage   = null;
      _selectedTerm    = null;
    });
  }

  void _saveTeacher() {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid) return;

    if (_assignedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إضافة مادة واحدة على الأقل',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // بياناتك جاهزة للإرسال للـ Backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ المعلم وتعيين مواده بنجاح!',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Color(0xFF005F61),
      ),
    );
    Navigator.pop(context);
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.16;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ── المحتوى القابل للتمرير ──
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── البيانات الأساسية ──
                      _buildTextField(
                        label:      'اسم المعلم الكامل',
                        controller: _nameController,
                        icon:       Icons.person_rounded,
                        validator:  (val) =>
                            val!.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 14),

                      _buildTextField(
                        label:         'البريد الإلكتروني',
                        controller:    _emailController,
                        icon:          Icons.email_rounded,
                        keyboardType:  TextInputType.emailAddress,
                        validator:     (val) {
                          if (val!.trim().isEmpty) return 'هذا الحقل مطلوب';
                          final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
                          if (!emailRegex.hasMatch(val.trim())) {
                            return 'صيغة البريد الإلكتروني غير صحيحة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      _buildTextField(
                        label:            'رقم الموبايل',
                        controller:       _phoneController,
                        icon:             Icons.phone_android_rounded,
                        keyboardType:     TextInputType.phone,
                        inputFormatters:  [FilteringTextInputFormatter.digitsOnly],
                        validator:        (val) {
                          if (val!.trim().isEmpty) return 'هذا الحقل مطلوب';
                          if (val.trim().length < 10) {
                            return 'رقم الموبايل يجب أن يكون 10 أرقام على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── الباسورد ──
                      _buildPasswordField(
                        label:      'كلمة المرور',
                        controller: _passwordController,
                        obscure:    _obscurePassword,
                        onToggle:   () => setState(() => _obscurePassword = !_obscurePassword),
                        validator:  (val) {
                          if (val!.isEmpty) return 'هذا الحقل مطلوب';
                          if (val.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      _buildPasswordField(
                        label:      'تأكيد كلمة المرور',
                        controller: _confirmController,
                        obscure:    _obscureConfirm,
                        onToggle:   () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator:  (val) {
                          if (val!.isEmpty) return 'هذا الحقل مطلوب';
                          if (val != _passwordController.text) {
                            return 'كلمتا المرور غير متطابقتين';
                          }
                          return null;
                        },
                      ),

                      // ── قسم تعيين المواد ──
                      const SizedBox(height: 24),
                      _buildSectionTitle('إضافة مادة دراسية'),
                      const SizedBox(height: 10),

                      // اختيار المادة (ديناميكي بناءً على الصف)
                      DropdownButtonFormField<String>(
                        value:      _selectedSubject,
                        decoration: _inputDecoration('المادة الدراسية', Icons.book_rounded).copyWith(
                          hintText: _selectedStage == null
                              ? 'اختر المرحلة أولاً'
                              : 'اختر المادة',
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                        ),
                        isExpanded: true,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
                        items: _availableSubjects
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: _selectedStage == null
                            ? null
                            : (val) => setState(() => _selectedSubject = val),
                      ),
                      const SizedBox(height: 10),

                      // اختيار المرحلة
                      _buildDropdown(
                        label:     'المرحلة الدراسية',
                        icon:      Icons.school_rounded,
                        items:     _stages,
                        value:     _selectedStage,
                        onChanged: (val) => setState(() {
                          _selectedStage   = val;
                          _selectedSubject = null; // إعادة تعيين المادة عند تغيير الصف
                        }),
                      ),
                      const SizedBox(height: 10),

                      // اختيار الترم + زر الإضافة
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label:     'الترم',
                              icon:      Icons.calendar_month_rounded,
                              items:     _terms,
                              value:     _selectedTerm,
                              onChanged: (val) => setState(() => _selectedTerm = val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF005F61),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              onPressed: _addSubject,
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              tooltip: 'إضافة المادة',
                            ),
                          ),
                        ],
                      ),

                      // ── عرض المواد المضافة ──
                      if (_assignedSubjects.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionTitle('المواد المعيّنة (${_assignedSubjects.length})'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing:   8,
                          runSpacing: 8,
                          children: _assignedSubjects
                              .map((entry) => _buildSubjectChip(entry))
                              .toList(),
                        ),
                      ],

                      // ── زر الحفظ ──
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveTeacher,
                          icon: const Icon(Icons.save_rounded, color: Colors.white),
                          label: const Text(
                            'حفظ المعلم',
                            style: TextStyle(
                              fontFamily:  'Cairo',
                              fontSize:    16,
                              fontWeight:  FontWeight.bold,
                              color:       Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005F61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── الهيدر الموحد ──
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: ()  {Navigator.pop(context);}
                      ),
                      const Text(
                        'إضافة معلم جديد',
                        style: TextStyle(
                          fontFamily:  'Cairo',
                          fontSize:    18,
                          fontWeight:  FontWeight.bold,
                          color:       Colors.white,
                        ),
                      ),
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

  // ─────────────────────────────────────────────
  //  Widgets مساعدة
  // ─────────────────────────────────────────────

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontFamily:  'Cairo',
      fontSize:    13,
      fontWeight:  FontWeight.bold,
      color:       Colors.grey,
    ),
  );

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText:   label,
    labelStyle:  const TextStyle(fontFamily: 'Cairo', fontSize: 13),
    prefixIcon:  Icon(icon, color: const Color(0xFF005F61)),
    border:      OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:   const BorderSide(color: Color(0xFF005F61), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller:       controller,
        keyboardType:     keyboardType,
        inputFormatters:  inputFormatters,
        style:            const TextStyle(fontFamily: 'Cairo'),
        decoration:       _inputDecoration(label, icon),
        validator:        validator,
      );

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller:    controller,
        obscureText:   obscure,
        style:         const TextStyle(fontFamily: 'Cairo'),
        decoration:    _inputDecoration(label, Icons.lock_rounded).copyWith(
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: const Color(0xFF005F61),
            ),
          ),
        ),
        validator: validator,
      );

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) =>
      DropdownButtonFormField<String>(
        value:       value,
        decoration:  _inputDecoration(label, icon),
        isExpanded:  true,
        style:       const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
        items:       items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ))
            .toList(),
        onChanged: onChanged,
      );

  Widget _buildSubjectChip(_AssignedSubject entry) {
    // لون مختلف حسب المرحلة
    final bool isPrimary = entry.stage.contains('الابتدائي');
    final Color chipColor = isPrimary
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFE3F2FD);
    final Color textColor = isPrimary
        ? const Color(0xFF2E7D32)
        : const Color(0xFF1565C0);

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: textColor.withOpacity(0.15),
        child: Text(
          entry.subject.substring(0, 1),
          style: TextStyle(
            fontFamily:  'Cairo',
            fontSize:    11,
            fontWeight:  FontWeight.bold,
            color:       textColor,
          ),
        ),
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:       MainAxisSize.min,
        children: [
          Text(
            entry.subject,
            style: TextStyle(
              fontFamily:  'Cairo',
              fontSize:    12,
              fontWeight:  FontWeight.bold,
              color:       textColor,
            ),
          ),
          Text(
            '${entry.stage} | ${entry.term}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   10,
              color:      textColor.withOpacity(0.75),
            ),
          ),
        ],
      ),
      onDeleted: () => setState(() => _assignedSubjects.remove(entry)),
      deleteIcon: Icon(Icons.close_rounded, size: 15, color: textColor),
      backgroundColor:  chipColor,
      side:             BorderSide(color: textColor.withOpacity(0.3)),
      padding:          const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    );
  }
}