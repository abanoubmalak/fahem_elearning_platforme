// lib/features/admin/presentation/screens/teachers/edit_teacher_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────
// نموذج بيانات المادة
// ─────────────────────────────────────────────
class AssignedSubject {
  final String subjectCode;
  final String subjectName;
  final String stage;
  final String term;

  AssignedSubject({
    required this.subjectCode,
    required this.subjectName,
    required this.stage,
    required this.term,
  });

  bool matches(AssignedSubject other) =>
      subjectCode == other.subjectCode &&
      stage == other.stage &&
      term == other.term;
}

// ─────────────────────────────────────────────
// الشاشة الرئيسية
// ─────────────────────────────────────────────
class EditTeacherScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const EditTeacherScreen({super.key, required this.teacherData});

  @override
  State<EditTeacherScreen> createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // ── Subject picker state ──
  String? _selectedSubject;
  String? _selectedStage;
  String? _selectedTerm;

  // ── Assigned subjects list ──
  late List<AssignedSubject> _assignedSubjects;

  bool _isSaving = false;

  // ── Static data ──
  static const Map<String, List<String>> _subjectsByStage = {
    'الصف الأول الابتدائي': ['لغة عربية', 'لغة إنجليزية', 'رياضيات'],
    'الصف الثاني الابتدائي': ['لغة عربية', 'لغة إنجليزية', 'رياضيات'],
    'الصف الثالث الابتدائي': ['لغة عربية', 'لغة إنجليزية', 'رياضيات'],
    'الصف الرابع الابتدائي': [
      'لغة عربية',
      'لغة إنجليزية',
      'رياضيات',
      'علوم',
      'دراسات اجتماعية'
    ],
    'الصف الخامس الابتدائي': [
      'لغة عربية',
      'لغة إنجليزية',
      'رياضيات',
      'علوم',
      'دراسات اجتماعية'
    ],
    'الصف السادس الابتدائي': [
      'لغة عربية',
      'لغة إنجليزية',
      'رياضيات',
      'علوم',
      'دراسات اجتماعية'
    ],
    'الصف الأول الإعدادي': [
      'لغة عربية',
      'لغة إنجليزية',
      'رياضيات',
      'علوم',
      'دراسات اجتماعية'
    ],
    'الصف الثاني الإعدادي': [
      'لغة عربية',
      'لغة إنجليزية',
      'رياضيات',
      'علوم',
      'دراسات اجتماعية'
    ],
    'الصف الثالث الإعدادي': [
      'لغة عربية',
      'لغة إنجليزية',
      'رياضيات',
      'علوم',
      'دراسات اجتماعية'
    ],
  };

  static const Map<String, String> _subjectCodes = {
    'لغة عربية': 'arabic',
    'لغة إنجليزية': 'english',
    'رياضيات': 'math',
    'علوم': 'sci',
    'دراسات اجتماعية': 'social',
  };

  static const Map<String, String> _reverseSubjectCodes = {
    'arabic': 'لغة عربية',
    'english': 'لغة إنجليزية',
    'math': 'رياضيات',
    'sci': 'علوم',
    'social': 'دراسات اجتماعية',
  };

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

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.teacherData['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.teacherData['email'] ?? '');
    _phoneController =
        TextEditingController(text: widget.teacherData['phone'] ?? '');

    final List<dynamic> existingCourses =
        (widget.teacherData['assignedCourses'] as List<dynamic>?) ?? [];

    final Set<String> seenKeys = {};
    _assignedSubjects = [];

    for (final course in existingCourses) {
      if (course is! Map) continue;

      final subjectCode = (course['subject'] ?? '').toString();
      final stage = (course['stage'] ?? '').toString();
      final term = (course['term'] ?? '').toString();

      final key = '$subjectCode|$stage|$term';
      if (seenKeys.contains(key)) continue;
      seenKeys.add(key);

      _assignedSubjects.add(
        AssignedSubject(
          subjectCode: subjectCode,
          subjectName: _reverseSubjectCodes[subjectCode] ?? subjectCode,
          stage: stage,
          term: term,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Validation helpers
  // ─────────────────────────────────────────────
  bool _isValidEmail(String value) {
    final email = value.trim();
    final emailRegex = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String value) {
    final phone = value.trim();
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  String? _subjectCodeFromName(String subjectName) {
    return _subjectCodes[subjectName];
  }

  // ─────────────────────────────────────────────
  // Firestore check: هل المادة واخدها معلم آخر؟
  // ─────────────────────────────────────────────
  Future<String?> _findTeacherWhoAlreadyHasSubject({
    required String subjectCode,
    required String stage,
    required String term,
  }) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('teachers').get();

      final currentTeacherId = widget.teacherData['id']?.toString();

      for (final doc in snapshot.docs) {
        if (currentTeacherId != null && doc.id == currentTeacherId) {
          continue;
        }

        final data = doc.data();
        final coursesRaw = data['assignedCourses'];

        if (coursesRaw is! List) continue;

        final courses = coursesRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        final exists = courses.any((course) =>
            course['subject'] == subjectCode &&
            course['stage'] == stage &&
            course['term'] == term);

        if (exists) {
          return (data['name'] ?? doc.id).toString();
        }
      }

      return null;
    } catch (_) {
      return 'error';
    }
  }

  // ─────────────────────────────────────────────
  // Logic
  // ─────────────────────────────────────────────
  Future<void> _addSubject() async {
    if (_selectedStage == null ||
        _selectedSubject == null ||
        _selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار المرحلة والمادة والترم أولاً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final subjectCode = _subjectCodeFromName(_selectedSubject!);
    if (subjectCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'المادة المختارة غير صحيحة',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newEntry = AssignedSubject(
      subjectCode: subjectCode,
      subjectName: _selectedSubject!,
      stage: _selectedStage!,
      term: _selectedTerm!,
    );

    if (_assignedSubjects.any((e) => e.matches(newEntry))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'هذه المادة مضافة بالفعل داخل نفس التعديل',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final teacherName = await _findTeacherWhoAlreadyHasSubject(
      subjectCode: newEntry.subjectCode,
      stage: newEntry.stage,
      term: newEntry.term,
    );

    if (!mounted) return;

    if (teacherName == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء التحقق من المواد',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (teacherName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذه المادة متاحة بالفعل عند المعلم: $teacherName',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _assignedSubjects.add(newEntry);
      _selectedSubject = null;
      _selectedTerm = null;
    });
  }

  Future<void> _saveChanges() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'من فضلك راجع الحقول المطلوبة',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_assignedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لازم تضيف مادة واحدة على الأقل للمعلم',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final teacherId = widget.teacherData['id']?.toString();
    if (teacherId == null || teacherId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحديد بيانات المعلم',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      for (final subjectObj in _assignedSubjects) {
        final teacherName = await _findTeacherWhoAlreadyHasSubject(
          subjectCode: subjectObj.subjectCode,
          stage: subjectObj.stage,
          term: subjectObj.term,
        );

        if (!mounted) return;

        if (teacherName == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'حدث خطأ أثناء التحقق من المواد قبل الحفظ',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        if (teacherName != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لا يمكن الحفظ لأن المادة "${subjectObj.subjectName}" متاحة بالفعل عند المعلم: $teacherName',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      final List<dynamic> oldCourses =
          (widget.teacherData['assignedCourses'] as List<dynamic>?) ?? [];

      final updatedCoursesList = _assignedSubjects.map((subjectObj) {
        final existingCourse = oldCourses.firstWhere(
          (c) =>
              c is Map &&
              c['subject'] == subjectObj.subjectCode &&
              c['stage'] == subjectObj.stage &&
              c['term'] == subjectObj.term,
          orElse: () => <String, dynamic>{},
        );

        return {
          'subject': subjectObj.subjectCode,
          'stage': subjectObj.stage,
          'term': subjectObj.term,
          'pdfs': existingCourse is Map ? (existingCourse['pdfs'] ?? 0) : 0,
          'quizzes': existingCourse is Map ? (existingCourse['quizzes'] ?? 0) : 0,
          'videos': existingCourse is Map ? (existingCourse['videos'] ?? 0) : 0,
        };
      }).toList();

      final teacherBasicData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'specialty': _assignedSubjects.isNotEmpty
            ? _assignedSubjects.first.subjectName
            : '',
      };

      final error = await context.read<AdminCubit>().updateTeacherData(
            teacherId: teacherId,
            newCourses: updatedCoursesList,
            teacherBasicData: teacherBasicData,
          );

      if (!mounted) return;

      if (error == null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تحديث البيانات بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ─────────────────────────────────────────────
  // Build
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
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'اسم المعلم الكامل',
                        controller: _nameController,
                        icon: Icons.person_rounded,
                        validator: (val) {
                          final text = val?.trim() ?? '';
                          if (text.isEmpty) return 'هذا الحقل مطلوب';
                          if (text.length < 3) {
                            return 'اسم المعلم يجب ألا يقل عن 3 أحرف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          final text = val?.trim() ?? '';
                          if (text.isEmpty) return 'هذا الحقل مطلوب';
                          if (!_isValidEmail(text)) {
                            return 'البريد الإلكتروني غير صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: 'رقم الموبايل',
                        controller: _phoneController,
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (val) {
                          final text = val?.trim() ?? '';
                          if (text.isEmpty) return 'هذا الحقل مطلوب';
                          if (!_isValidPhone(text)) {
                            return 'رقم الهاتف يجب أن يكون من 10 إلى 15 رقم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('إضافة مادة دراسية جديدة'),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedStage,
                        decoration: _inputDecoration(
                          'المرحلة الدراسية',
                          Icons.school_rounded,
                        ),
                        isExpanded: true,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        items: _stages
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اختر المرحلة الدراسية';
                          }
                          return null;
                        },
                        onChanged: (val) => setState(() {
                          _selectedStage = val;
                          _selectedSubject = null;
                        }),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSubject,
                              decoration: _inputDecoration(
                                'المادة الدراسية',
                                Icons.book_rounded,
                              ).copyWith(
                                hintText: _selectedStage == null
                                    ? 'اختر المرحلة أولاً'
                                    : 'اختر المادة',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              isExpanded: true,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              items: _availableSubjects
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'اختر المادة';
                                }
                                return null;
                              },
                              onChanged: _selectedStage == null
                                  ? null
                                  : (val) => setState(() => _selectedSubject = val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTerm,
                              decoration: _inputDecoration(
                                'الترم',
                                Icons.calendar_month_rounded,
                              ),
                              isExpanded: true,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              items: _terms
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'اختر الترم';
                                }
                                return null;
                              },
                              onChanged: (val) =>
                                  setState(() => _selectedTerm = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _addSubject,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'إضافة المادة للقائمة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005F61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (_assignedSubjects.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle(
                          'المواد الحالية للمعلم (${_assignedSubjects.length})',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _assignedSubjects
                              .map((entry) => _buildSubjectChip(entry))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveChanges,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'تعديل بيانات المعلم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  // Widgets مساعدة
  // ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      );

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF005F61)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF005F61),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      );

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: _inputDecoration(label, icon),
      validator: validator ??
          (val) {
            if ((val ?? '').trim().isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
    );
  }

  Widget _buildSubjectChip(AssignedSubject entry) {
    final bool isPrimary = entry.stage.contains('الابتدائي');
    final Color chipColor =
        isPrimary ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    final Color textColor =
        isPrimary ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: textColor.withOpacity(0.15),
        child: Text(
          entry.subjectName.isNotEmpty ? entry.subjectName.substring(0, 1) : '',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.subjectName,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            '${entry.stage} | ${entry.term}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: textColor.withOpacity(0.75),
            ),
          ),
        ],
      ),
      onDeleted: () => setState(() => _assignedSubjects.remove(entry)),
      deleteIcon: Icon(Icons.close_rounded, size: 15, color: textColor),
      backgroundColor: chipColor,
      side: BorderSide(color: textColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    );
  }
}