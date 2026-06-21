// lib/features/admin/presentation/screens/teachers/teacher_details_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  نموذج بيانات المادة (يفضل نقله لملف models لاحقاً ليكون مشتركاً)
// ─────────────────────────────────────────────
class AssignedSubject {
  final String subject;
  final String stage;
  final String term;

  AssignedSubject({
    required this.subject,
    required this.stage,
    required this.term,
  });
}

// ─────────────────────────────────────────────
//  شاشة عرض التفاصيل
// ─────────────────────────────────────────────
class TeacherDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const TeacherDetailsScreen({super.key, required this.teacherData});

  @override
  State<TeacherDetailsScreen> createState() => _TeacherDetailsScreenState();
}

class _TeacherDetailsScreenState extends State<TeacherDetailsScreen> {
  late Map<String, dynamic> _teacher;
  late List<AssignedSubject> _assignedSubjects;
@override
void initState() {
  super.initState();

  _teacher = Map<String, dynamic>.from(widget.teacherData);

  final courses = List<Map<String, dynamic>>.from(
    _teacher['assignedCourses'] ?? [],
  );

  const reverseSubjectCodes = {
    'arabic': 'لغة عربية',
    'english': 'لغة إنجليزية',
    'math': 'رياضيات',
    'sci': 'علوم',
    'social': 'دراسات اجتماعية',
  };

  _assignedSubjects = courses.map((course) {
    return AssignedSubject(
      subject: reverseSubjectCodes[course['subject']] ??
          course['subject'],
      stage: course['stage'] ?? '',
      term: course['term'] ?? '',
    );
  }).toList();
}

  // ── دالة تأكيد الحذف ──
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف المعلم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من حذف المعلم "${_teacher['name']}" نهائياً من المنصة؟', style: const TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // TODO: تنفيذ الحذف عبر API
                Navigator.pop(ctx); 
                Navigator.pop(context, {'action': 'delete', 'id': _teacher['id']});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف المعلم بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                );
              },
              child: const Text('حذف نهائياً', style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // كارت البيانات الأساسية
                    _buildMainInfoCard(),
                    
                    const SizedBox(height: 20),
                    
                    // كارت المواد الأكاديمية
                    _buildAcademicInfoCard(),

                    const SizedBox(height: 40),

                    // ── أزرار التحكم ──
                    Row(
                      children: [
                        // زر التعديل
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () async {
  final updated = await Navigator.pushNamed(
    context,
    Routes.EditTeacherScreen,
    arguments: _teacher,
  );

  if (updated == true && mounted) {
    Navigator.pop(context, {'action': 'refresh'});
  }
},
                              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                              label: const Text('تعديل البيانات', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005F61),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // زر الحذف
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _confirmDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context)
                      ),
                      const Text(
                        'تفاصيل المعلم',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildMainInfoCard() {
    final bool isActive = _teacher['isActive'] ?? true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFFEDF7F7),
                child: Text(_teacher['name']?.substring(0, 1) ?? 'م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
                child: Text(isActive ? 'حساب نشط' : 'حساب موقوف', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade700 : Colors.red.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_teacher['name'] ?? 'بدون اسم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          ),
          const Divider(height: 30),
          _buildInfoRow(Icons.email_outlined, _teacher['email'] ?? 'لا يوجد بريد إلكتروني'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, _teacher['phone'] ?? 'لا يوجد رقم هاتف'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey.shade700))),
      ],
    );
  }

  Widget _buildAcademicInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('المواد المعينة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 16),
          if (_assignedSubjects.isEmpty)
            Text('لم يتم تعيين مواد لهذا المعلم.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey.shade500))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _assignedSubjects.map((entry) => _buildSubjectChip(entry)).toList(),
            ),
        ],
      ),
    );
  }

  // ── دالة بناء التاج (مطابقة تماماً لشاشة الإضافة لكن للعرض فقط) ──
  Widget _buildSubjectChip(AssignedSubject entry) {
    final bool isPrimary = entry.stage.contains('الابتدائي');
    final Color chipColor = isPrimary ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    final Color textColor = isPrimary ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: textColor.withOpacity(0.15),
        child: Text(
          entry.subject.substring(0, 1),
          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(entry.subject, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
          Text('${entry.stage} | ${entry.term}', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: textColor.withOpacity(0.75))),
        ],
      ),
      // إزالة خاصية onDeleted لمنع الحذف من شاشة العرض
      backgroundColor: chipColor,
      side: BorderSide(color: textColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    );
  }
}