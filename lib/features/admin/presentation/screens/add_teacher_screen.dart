import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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

  bool matches(_AssignedSubject other) =>
      subject == other.subject && stage == other.stage && term == other.term;
}

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController  = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  String? _selectedStage;
  String? _selectedTerm;
  String? _selectedSubject;

  final List<_AssignedSubject> _assignedSubjects = [];

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

  final List<String> _stages = [
    'الصف الأول الابتدائي', 'الصف الثاني الابتدائي', 'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي', 'الصف الخامس الابتدائي', 'الصف السادس الابتدائي',
    'الصف الأول الإعدادي', 'الصف الثاني الإعدادي', 'الصف الثالث الإعدادي',
  ];

  final List<String> _terms = ['الترم الأول', 'الترم الثاني'];
  static const Map<String, String> subjectCodes = {
  'لغة عربية': 'arabic',
  'لغة إنجليزية': 'english',
  'رياضيات': 'math',
  'علوم': 'sci',
  'دراسات اجتماعية': 'social',
};

  List<String> _getAvailableSubjects(AdminState state) {
    if (_selectedStage == null || _selectedTerm == null) return [];
    
    List<String> baseSubjects = _subjectsByStage[_selectedStage!] ?? [];
    Set<String> takenSubjects = {};

   if (state is AdminLoaded) {
  for (var teacher in state.teachers) {
    List courses = teacher['assignedCourses'] ?? [];

    for (var course in courses) {
      if (course['stage'] == _selectedStage &&
          course['term'] == _selectedTerm) {

        String? subjectName;

        subjectCodes.forEach((name, code) {
          if (code == course['subject']) {
            subjectName = name;
          }
        });

        if (subjectName != null) {
          takenSubjects.add(subjectName!);
        }
      }
    }
  }
}

    for (var assigned in _assignedSubjects) {
      if (assigned.stage == _selectedStage && assigned.term == _selectedTerm) {
        takenSubjects.add(assigned.subject);
      }
    }

    return baseSubjects.where((sub) => !takenSubjects.contains(sub)).toList();
  }

Set<String> _getTakenSubjects(AdminState state) {
  Set<String> taken = {};

  if (state is AdminLoaded) {
    for (var teacher in state.teachers) {
      List courses = teacher['assignedCourses'] ?? [];

      for (var course in courses) {
        if (course['stage'] == _selectedStage &&
            course['term'] == _selectedTerm) {
          subjectCodes.forEach((name, code) {
  if (code == course['subject']) {
    taken.add(name);
  }
});
        }
      }
    }
  }

  return taken;
}


  void _addSubject() {
    if (_selectedSubject == null || _selectedStage == null || _selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المرحلة والترم والمادة بالترتيب', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.orange),
      );
      return;
    }

    final newEntry = _AssignedSubject(subject: _selectedSubject!, stage: _selectedStage!, term: _selectedTerm!);

    setState(() {
      _assignedSubjects.add(newEntry);
      _selectedSubject = null; 
    });
  }

Future<void> _saveTeacher() async {
  if (!_formKey.currentState!.validate()) return;

  if (_assignedSubjects.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'يجب اختيار مادة واحدة على الأقل',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
    return;
  }

  final uid =
      FirebaseFirestore.instance.collection('teachers').doc().id;

  final teacherData = {
    'uid': uid,

    'name': _nameController.text.trim(),

    'phone': _phoneController.text.trim(),

    'email': _emailController.text.trim(),

    'password': _passwordController.text.trim(),

    'specialty': _assignedSubjects.first.subject,

    'availableBalance': 0.0,

    'pendingBalance': 0.0,

    'averageScore': 0.0,

    'totalStudents': 0,

    'isActive': true,

    'assignedCourses': _assignedSubjects
        .map(
          (e) => {
            'subject': subjectCodes[e.subject] ?? e.subject,
            'stage': e.stage,
            'term': e.term,
            'videos': 0,
            'pdfs': 0,
            'quizzes': 0,
          },
        )
        .toList(),
  };

  final errorMessage =
      await context.read<AdminCubit>().addTeacherWithValidation(
            teacherData,
          );

  if (!mounted) return;

  if (errorMessage != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          errorMessage,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'تم إضافة المعلم بنجاح',
        style: TextStyle(fontFamily: 'Cairo'),
      ),
    ),
  );

  Navigator.pop(context);
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
              child: BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  List<String> availableSubjects = _getAvailableSubjects(state);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(label: 'اسم المعلم الكامل', controller: _nameController, icon: Icons.person_rounded, validator: (val) => val!.trim().isEmpty ? 'هذا الحقل مطلوب' : null),
                          const SizedBox(height: 14),
                          _buildTextField(label: 'البريد الإلكتروني', controller: _emailController, icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress, validator: (val) => val!.trim().isEmpty ? 'مطلوب' : null),
                          const SizedBox(height: 14),
                          _buildTextField(label: 'رقم الموبايل', controller: _phoneController, icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (val) => val!.trim().isEmpty ? 'مطلوب' : null),
                          const SizedBox(height: 14),
                          _buildPasswordField(label: 'كلمة المرور', controller: _passwordController, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), validator: (val) => val!.isEmpty ? 'مطلوب' : null),
                          const SizedBox(height: 14),
                          _buildPasswordField(label: 'تأكيد كلمة المرور', controller: _confirmController, obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm), validator: (val) => val != _passwordController.text ? 'غير متطابق' : null),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('إضافة مادة دراسية'),
                          const SizedBox(height: 10),

                          _buildDropdown(
                            label: 'المرحلة الدراسية', icon: Icons.school_rounded, items: _stages, value: _selectedStage,
                            onChanged: (val) => setState(() { _selectedStage = val; _selectedSubject = null; }),
                          ),
                          const SizedBox(height: 10),

                          _buildDropdown(
                            label: 'الترم', icon: Icons.calendar_month_rounded, items: _terms, value: _selectedTerm,
                            onChanged: (val) => setState(() { _selectedTerm = val; _selectedSubject = null; }),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSubject,
                                  decoration: _inputDecoration('المادة الدراسية', Icons.book_rounded).copyWith(
                                    hintText: (_selectedStage == null || _selectedTerm == null) ? 'اختر المرحلة والترم أولاً' : (availableSubjects.isEmpty ? 'جميع المواد محجوزة' : 'اختر المادة'),
                                    hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                                  ),
                                  isExpanded: true,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
                                  items: availableSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)))).toList(),
                                  onChanged: availableSubjects.isEmpty ? null : (val) => setState(() => _selectedSubject = val),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(color: const Color(0xFF005F61), borderRadius: BorderRadius.circular(14)),
                                child: IconButton(onPressed: _addSubject, icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28)),
                              ),
                            ],
                          ),

                          if (_assignedSubjects.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSectionTitle('المواد المعيّنة (${_assignedSubjects.length})'),
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, runSpacing: 8, children: _assignedSubjects.map((entry) => _buildSubjectChip(entry)).toList()),
                          ],

                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _saveTeacher, icon: const Icon(Icons.save_rounded, color: Colors.white),
                              label: const Text('حفظ المعلم', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),

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
                      const Text('إضافة معلم جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey));
  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13), prefixIcon: Icon(icon, color: const Color(0xFF005F61)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14));
  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) => TextFormField(controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, style: const TextStyle(fontFamily: 'Cairo'), decoration: _inputDecoration(label, icon), validator: validator);
  Widget _buildPasswordField({required String label, required TextEditingController controller, required bool obscure, required VoidCallback onToggle, String? Function(String?)? validator}) => TextFormField(controller: controller, obscureText: obscure, style: const TextStyle(fontFamily: 'Cairo'), decoration: _inputDecoration(label, Icons.lock_rounded).copyWith(suffixIcon: IconButton(onPressed: onToggle, icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFF005F61)))), validator: validator);
  Widget _buildDropdown({required String label, required IconData icon, required List<String> items, required String? value, required void Function(String?) onChanged}) => DropdownButtonFormField<String>(value: value, decoration: _inputDecoration(label, icon), isExpanded: true, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87), items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)))).toList(), onChanged: onChanged);
  
  Widget _buildSubjectChip(_AssignedSubject entry) {
    final bool isPrimary = entry.stage.contains('الابتدائي');
    final Color chipColor = isPrimary ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    final Color textColor = isPrimary ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);
    return Chip(
      avatar: CircleAvatar(backgroundColor: textColor.withOpacity(0.15), child: Text(entry.subject.substring(0, 1), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
      label: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(entry.subject, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: textColor)), Text('${entry.stage} | ${entry.term}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: textColor.withOpacity(0.75)))]),
      onDeleted: () => setState(() => _assignedSubjects.remove(entry)),
      deleteIcon: Icon(Icons.close_rounded, size: 15, color: textColor), backgroundColor: chipColor, side: BorderSide(color: textColor.withOpacity(0.3)), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    );
  }
}