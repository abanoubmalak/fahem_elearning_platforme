// lib/features/teacher/presentation/screens/manage_sections/lesson_content_hub_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_academic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'manage_media_content_screen.dart';
import 'manage_text_summary_screen.dart';
import 'manage_quiz_content_screen.dart';

class LessonContentHubScreen extends StatefulWidget {
  final String lessonName;
  final String unitName;
  final String stageName;
  final String subjectId;
  final String term;

  const LessonContentHubScreen({
    super.key, 
    required this.lessonName,
    required this.unitName,
    required this.stageName,
    required this.subjectId,
    required this.term,
  });

  @override
  State<LessonContentHubScreen> createState() => _LessonContentHubScreenState();
}

class _LessonContentHubScreenState extends State<LessonContentHubScreen> {
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;

    return BlocBuilder<TeacherAcademicCubit, TeacherAcademicState>(
      builder: (context, state) {
        bool hasVideo = false;
        bool hasSummary = false;
        bool hasQuiz = false;
        String? videoUrl;
        String? summaryText;
        List<dynamic>? questionsList;

        if (state is AcademicLoaded) {
          final unit = state.units.firstWhere((u) => u['title'] == widget.unitName, orElse: () => {});
          final lessons = unit['lessons'] ?? [];
          final lesson = lessons.firstWhere((l) => l['title'] == widget.lessonName, orElse: () => {});

          videoUrl = lesson['videoUrl'];
          final summariesList = lesson['summaries'] as List<dynamic>? ?? [];
          summaryText = summariesList.isNotEmpty ? summariesList.first.toString() : null;
          questionsList = lesson['questions'];

          hasVideo = (videoUrl ?? '').toString().isNotEmpty;
          hasSummary = (summaryText ?? '').toString().isNotEmpty;
          hasQuiz = (questionsList ?? []).isNotEmpty;
        }

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('اختر القسم المطلوب إدارته:', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 16),

                        // 1️⃣ كارت إدارة الفيديو
                        _buildHubCard(
                          title: 'فيديو الشرح', subtitle: 'رفع، تعديل، أو حذف فيديو الدرس',
                          icon: Icons.play_circle_fill_rounded, iconBgColor: const Color(0xFFEDF7F7), iconColor: const Color(0xFF005F61),
                          isAdded: hasVideo,
                          onTap: () {
                            // 👈 استخراج الكوبيت مسبقاً لتفادي تحذير الـ Async Gap
                            final academicCubit = BlocProvider.of<TeacherAcademicCubit>(context);
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ManageMediaContentScreen(
                                lessonName: widget.lessonName, 
                                initialContent: videoUrl
                              ),
                            )).then((newVideoUrl) {
                              if (state is AcademicLoaded) {
                                academicCubit.updateLessonContent(
                                  subjectId: widget.subjectId, term: widget.term, unitTitle: widget.unitName, lessonTitle: widget.lessonName,
                                  contentType: 'video', contentData: newVideoUrl ?? '', currentUnits: state.units,
                                );
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2️⃣ كارت إدارة الملخص
                        _buildHubCard(
                          title: 'الملخص والمذكرة', subtitle: 'كتابة وتحديث الملخص الأكاديمي للدرس',
                          icon: Icons.article_rounded, iconBgColor: const Color(0xFFE8F8F5), iconColor: const Color(0xFF27AE60),
                          isAdded: hasSummary,
                          onTap: () {
                            final academicCubit = BlocProvider.of<TeacherAcademicCubit>(context);
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ManageTextSummaryScreen(
                                lessonName: widget.lessonName, 
                                initialSummary: summaryText
                              ),
                            )).then((newSummary) {
                              if (state is AcademicLoaded) {
                                final data = newSummary == null || newSummary.toString().isEmpty ? [] : [newSummary];
                                academicCubit.updateLessonContent(
                                  subjectId: widget.subjectId, term: widget.term, unitTitle: widget.unitName, lessonTitle: widget.lessonName,
                                  contentType: 'summary', contentData: data, currentUnits: state.units,
                                );
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3️⃣ كارت إدارة الكويز (تم تمرير المعاملات الإجبارية سطر 127 وتأمين الـ Async Gap)
                        _buildHubCard(
                          title: 'اختبار الاستيعاب (MCQ)', subtitle: 'إضافة وتعديل أسئلة واختيارات الامتحان',
                          icon: Icons.assignment_turned_in_rounded, iconBgColor: const Color(0xFFFEF6E5), iconColor: const Color(0xFFE6A100),
                          isAdded: hasQuiz,
                          onTap: () {
                            final academicCubit = BlocProvider.of<TeacherAcademicCubit>(context);
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ManageQuizContentScreen(
                                lessonName: widget.lessonName, 
                                unitName: widget.unitName,     // 👈 إصلاح خطأ سطر 127 ممرر 1
                                subjectId: widget.subjectId,   // 👈 إصلاح خطأ سطر 127 ممرر 2
                                term: widget.term,             // 👈 BC إصلاح خطأ سطر 127 ممرر 3
                                initialQuestions: questionsList,
                              ),
                            )).then((newQuestions) {
                              if (newQuestions != null && state is AcademicLoaded) {
                                academicCubit.updateLessonContent(
                                  subjectId: widget.subjectId, term: widget.term, unitTitle: widget.unitName, lessonTitle: widget.lessonName,
                                  contentType: 'quiz', contentData: newQuestions, currentUnits: state.units,
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 0, left: 0, right: 0, height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context), 
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('إدارة محتويات الدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
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
      },
    ); 
  }

  Widget _buildHubCard({required String title, required String subtitle, required IconData icon, required Color iconBgColor, required Color iconColor, required bool isAdded, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isAdded ? iconColor.withAlpha((0.3 * 255).toInt()) : Colors.grey[200]!, width: 1.2), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(width: 55, height: 55, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isAdded ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(8)),
                    child: Text(isAdded ? 'متوفر ومضاف ✔' : 'غير مضاف ✖', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: isAdded ? const Color(0xFF27AE60) : Colors.redAccent)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)), child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF005F61))),
          ],
        ),
      ),
    );
  }
}