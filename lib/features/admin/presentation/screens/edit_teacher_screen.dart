// lib/features/admin/presentation/screens/teachers/edit_teacher_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:http/http.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────
// نموذج بيانات المادة (تأكد من توحيده في ملف منفصل لاحقاً)
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

  // ── Static data ──
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

  List<String> get _availableSubjects =>
      _selectedStage != null ? (_subjectsByStage[_selectedStage!] ?? []) : [];

  final List<String> _stages = [
    'الصف الأول الابتدائي', 'الصف الثاني الابتدائي', 'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي', 'الصف الخامس الابتدائي', 'الصف السادس الابتدائي',
    'الصف الأول الإعدادي', 'الصف الثاني الإعدادي', 'الصف الثالث الإعدادي',
  ];

  final List<String> _terms = ['الترم الأول', 'الترم الثاني'];

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات الحالية للمعلم في الحقول
    _nameController = TextEditingController(text: widget.teacherData['name'] ?? '');
    _emailController = TextEditingController(text: widget.teacherData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.teacherData['phone'] ?? '');
    const reverseSubjectCodes = {
  'arabic': 'لغة عربية',
  'english': 'لغة إنجليزية',
  'math': 'رياضيات',
  'sci': 'علوم',
  'social': 'دراسات اجتماعية',
};

final List<dynamic>? existingCourses =
    widget.teacherData['assignedCourses'];

_assignedSubjects = [];

if (existingCourses != null) {
  for (var course in existingCourses) {
    _assignedSubjects.add(
 AssignedSubject(
   subjectCode: course['subject'],
   subjectName: reverseSubjectCodes[course['subject']] ?? course['subject'],
   stage: course['stage'],
   term: course['term'],
 ),
);
  }
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
  // Logic
  // ─────────────────────────────────────────────
  void _addSubject() {
    if (_selectedSubject == null || _selectedStage == null || _selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المادة والمرحلة والترم أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.orange));
      return;
    }

const subjectCodes = {
 'لغة عربية':'arabic',
 'لغة إنجليزية':'english',
 'رياضيات':'math',
 'علوم':'sci',
 'دراسات اجتماعية':'social',
};


final newEntry = AssignedSubject(
 subjectCode: subjectCodes[_selectedSubject]!,
 subjectName: _selectedSubject!,
 stage: _selectedStage!,
 term: _selectedTerm!,
);
    if (_assignedSubjects.any((e) => e.matches(newEntry))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذه المادة مضافة بالفعل', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.orange));
      return;
    }

    setState(() {
      _assignedSubjects.add(newEntry);
      _selectedSubject = null;
    });
  }
void _saveChanges() async {
  // 1. جلب البيانات القديمة الموجودة مسبقاً للمقارنة
  final List<dynamic> oldCourses = widget.teacherData['assignedCourses'] ?? [];

  // 2. تحويل القائمة المحلية إلى قائمة خرائط (Map) مع الحفاظ على قيم الموارد القديمة إن وجدت
  final updatedCoursesList = _assignedSubjects.map((subjectObj) {

final existingCourse = oldCourses.firstWhere(
 (c)=> 
 c['subject']==subjectObj.subjectCode &&
 c['stage']==subjectObj.stage &&
 c['term']==subjectObj.term,
 orElse: ()=>{},
);


return {

'subject':subjectObj.subjectCode,

'stage':subjectObj.stage,

'term':subjectObj.term,


'pdfs': existingCourse['pdfs'] ?? 0,

'quizzes': existingCourse['quizzes'] ?? 0,

'videos': existingCourse['videos'] ?? 0,

};

}).toList();

  // 3. تجهيز البيانات الأساسية
  final Map<String, dynamic> teacherBasicData = {
    'name': _nameController.text.trim(),
    'phone': _phoneController.text.trim(),
    'email': _emailController.text.trim(),
    // تحديث التخصص بناءً على أول مادة مضافة
'specialty': _assignedSubjects.isNotEmpty
 ? _assignedSubjects.first.subjectName
 : '',  };

  // 4. استدعاء الـ Cubit
  // تأكد أن الدالة في الـ Cubit تستخدم .update وليس .set
  final error = await context.read<AdminCubit>().updateTeacherData(
    teacherId: widget.teacherData['id'], 
    newCourses: updatedCoursesList,
    teacherBasicData: teacherBasicData,
  );

  if (error == null) {
        Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث البيانات بنجاح')));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
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
                      // ── البيانات الأساسية ──
                      _buildTextField(label: 'اسم المعلم الكامل', controller: _nameController, icon: Icons.person_rounded),
                      const SizedBox(height: 14),
                      _buildTextField(label: 'البريد الإلكتروني', controller: _emailController, icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: 'رقم الموبايل', controller: _phoneController, icon: Icons.phone_android_rounded, 
                        keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly]
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // ── قسم تعيين وتعديل المواد ──
                      _buildSectionTitle('إضافة مادة دراسية جديدة'),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: _selectedStage,
                        decoration: _inputDecoration('المرحلة الدراسية', Icons.school_rounded),
                        isExpanded: true,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
                        items: _stages.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                        onChanged: (val) => setState(() {
                          _selectedStage = val;
                          _selectedSubject = null; // إعادة تعيين المادة عند تغيير الصف
                        }),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSubject,
                              decoration: _inputDecoration('المادة الدراسية', Icons.book_rounded).copyWith(
                                hintText: _selectedStage == null ? 'اختر المرحلة أولاً' : 'اختر المادة',
                                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                              ),
                              isExpanded: true,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
                              items: _availableSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                              onChanged: _selectedStage == null ? null : (val) => setState(() => _selectedSubject = val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTerm,
                              decoration: _inputDecoration('الترم', Icons.calendar_month_rounded),
                              isExpanded: true,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
                              items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                              onChanged: (val) => setState(() => _selectedTerm = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: _addSubject,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('إضافة المادة للقائمة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),

                      // ── عرض المواد المضافة الحالية ──
                      if (_assignedSubjects.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle('المواد الحالية للمعلم (${_assignedSubjects.length})'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _assignedSubjects.map((entry) => _buildSubjectChip(entry)).toList(),
                        ),
                      ],

                      // ── زر الحفظ ──
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save_rounded, color: Colors.white),
                          label: const Text('حفظ التعديلات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      const Text('تعديل بيانات المعلم', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey));

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
    prefixIcon: Icon(icon, color: const Color(0xFF005F61)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: _inputDecoration(label, icon),
      validator: (val) => val!.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildSubjectChip(AssignedSubject entry) {
    final bool isPrimary = entry.stage.contains('الابتدائي');
    final Color chipColor = isPrimary ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    final Color textColor = isPrimary ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

    return Chip(
      avatar: CircleAvatar(backgroundColor: textColor.withOpacity(0.15), child: Text(entry.subjectName.substring(0, 1), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(entry.subjectName, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
          Text('${entry.stage} | ${entry.term}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: textColor.withOpacity(0.75))),
        ],
      ),
      onDeleted: () => setState(() => _assignedSubjects.remove(entry)), // هنا تعمل حذف للمادة من القائمة
      deleteIcon: Icon(Icons.close_rounded, size: 15, color: textColor),
      backgroundColor: chipColor,
      side: BorderSide(color: textColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    );
  }
}