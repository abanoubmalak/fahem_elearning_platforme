// lib/features/teacher/presentation/screens/manage_sections/manage_quiz_content_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_academic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'teacher_quiz_editor_screen.dart';

class ManageQuizContentScreen extends StatefulWidget {
  final String lessonName;
  final String unitName;
  final String subjectId;
  final String term;
  final List<dynamic>? initialQuestions; 

  const ManageQuizContentScreen({
    super.key,
    required this.lessonName,
    required this.unitName,
    required this.subjectId,
    required this.term,
    this.initialQuestions,
  });

  @override
  State<ManageQuizContentScreen> createState() => _ManageQuizContentScreenState();
}

class _ManageQuizContentScreenState extends State<ManageQuizContentScreen> {
  List<dynamic>? _serverQuestions;

  @override
  void initState() {
    super.initState();
    _serverQuestions = widget.initialQuestions;
  }

  void _navigateToEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherQuizEditorScreen(
          lessonName: widget.lessonName,
          initialQuestions: _serverQuestions,
        ),
      ),
    ).then((updatedQuestions) {
      if (updatedQuestions != null) {
        final state = context.read<TeacherAcademicCubit>().state;
        if (state is AcademicLoaded) {
          context.read<TeacherAcademicCubit>().updateLessonContent(
            subjectId: widget.subjectId, term: widget.term, unitTitle: widget.unitName, lessonTitle: widget.lessonName,
            contentType: 'quiz', contentData: updatedQuestions, currentUnits: state.units,
          );
        }
        setState(() => _serverQuestions = updatedQuestions as List<dynamic>);
      }
    });
  }

  void _deleteEntireQuiz() {
    final state = context.read<TeacherAcademicCubit>().state;
    if (state is AcademicLoaded) {
      context.read<TeacherAcademicCubit>().updateLessonContent(
        subjectId: widget.subjectId, term: widget.term, unitTitle: widget.unitName, lessonTitle: widget.lessonName,
        contentType: 'quiz', contentData: [], currentUnits: state.units,
      );
    }
    setState(() => _serverQuestions = null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الاختبار بالكامل', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;
    final bool hasQuiz = _serverQuestions != null && _serverQuestions!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: hasQuiz ? const Color(0xFFFEF6E5) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: hasQuiz ? const Color(0xFFE6A100).withAlpha((0.3 * 255).toInt()) : Colors.grey[300]!, width: 1.5)),
                      child: Column(
                        children: [
                          Icon(hasQuiz ? Icons.assignment_turned_in_rounded : Icons.quiz_outlined, color: hasQuiz ? const Color(0xFFE6A100) : Colors.grey[400], size: 44),
                          const SizedBox(height: 12),
                          Text(hasQuiz ? 'الاختبار متاح وجاهز حالياً' : 'لا يوجد اختبار مضاف لهذا الدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: hasQuiz ? const Color(0xFFD49400) : Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    if (!hasQuiz) ...[
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _navigateToEditor, icon: const Icon(Icons.add_moderator_rounded, color: Colors.white), label: const Text('إنشاء وتفعيل كويز جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                    ] else ...[
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _navigateToEditor, icon: const Icon(Icons.edit_attributes_rounded, color: Colors.white), label: const Text('تعديل وإدارة الأسئلة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _deleteEntireQuiz, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent), label: const Text('حذف الاختبار بجميع أسئلته نهائياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                    ]
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-20,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [const Text('إدارة الاختبار (MCQ)', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)])),
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
}