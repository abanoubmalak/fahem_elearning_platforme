// lib/features/lessons/presentation/screens/subject_details_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/lessons/presentation/screens/lessom_summery_screen.dart';
import 'package:fahem/features/lessons/presentation/widgets/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../cubit/subject_details_cubit.dart'; 
import '../widgets/unit_expansion_tile.dart';
import '../widgets/lesson_list_item.dart';
import 'quiz_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final String subjectId;
  final String subjectTitle;
  final String studentTerm;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
    required this.studentTerm,
  });

  IconData _getSubjectIcon(String id) {
    switch (id) {
      case 'ar': return Icons.menu_book_rounded;
      case 'en': return Icons.g_translate_rounded;
      case 'math': return Icons.calculate_rounded;
      case 'sci': return Icons.science_rounded;
      case 'soc': return Icons.public_rounded;
      default: return Icons.book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: BlocProvider(
        create: (context) => SubjectDetailsCubit()..fetchSyllabus(subjectId: subjectId, term: studentTerm),
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 85, 
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'محتوى مادة: $subjectTitle', 
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
          ),

          body: BlocBuilder<SubjectDetailsCubit, SubjectDetailsState>(
            builder: (context, state) {
              if (state is SubjectDetailsLoading || state is SubjectDetailsInitial) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61), strokeWidth: 4));
              }

              if (state is SubjectDetailsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      state.message, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF005F61), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }

              if (state is SubjectDetailsLoaded) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), 
                  padding: const EdgeInsets.symmetric(vertical: 24), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.04 * 255).toInt()), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: const Color(0xFFEDF7F7), borderRadius: BorderRadius.circular(16)),
                              child: Icon(_getSubjectIcon(subjectId), color: const Color(0xFF005F61), size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '$subjectTitle - $studentTerm', 
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), 
                          itemCount: state.units.length, 
                          itemBuilder: (context, index) {
                            final unit = state.units[index];
                            final List<dynamic> lessonsList = unit['lessons'] ?? [];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: UnitExpansionTile(
                                title: unit['title'] ?? 'وحدة دراسية غير مسماة',
                                initiallyExpanded: index == 0, 
                                lessons: lessonsList.map((lesson) {
                                  return LessonListItem(
                                    title: lesson['title'] ?? 'درس بدون عنوان',
                                    isCompleted: lesson['isCompleted'] ?? false,
                                    onWatchVideo: () {
                                      final String videoUrl = lesson['videoUrl'] ?? 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
                                      final List<dynamic> lessonQuiz = lesson['quiz'] ?? []; 

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VideoPlayerScreen(
                                            lessonTitle: lesson['title'] ?? 'فيديو الدرس',
                                            videoUrl: videoUrl, 
                                            questions: lessonQuiz, 
                                            // 👈 تمرير المتغيرات لضمان الحفظ في المادة الصحيحة
                                            subjectId: subjectId,
                                            studentTerm: studentTerm,
                                          ),
                                        ),
                                      );
                                    },
                                    onTakeQuiz: () {
                                      final List<dynamic> lessonQuiz = lesson['quiz'] ?? [];
                                      
                                      if (lessonQuiz.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('لا توجد أسئلة لهذا الدرس ⏳'), backgroundColor: Color(0xFF005F61))
                                        );
                                        return;
                                      }

                                      // 👈 توحيد الانتقال لـ MaterialPageRoute لحل كل مشاكل الراوتر
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => QuizScreen(
                                            lessonTitle: lesson['title'] ?? 'اختبار الدرس',
                                            questions: lessonQuiz,
                                            subjectId: subjectId,
                                            studentTerm: studentTerm,
                                          ),
                                        ),
                                      );
                                    },
                                    onViewSummary: () {
                                      final List<dynamic> lessonSummaries = lesson['summaries'] ?? []; 
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LessonSummaryScreen(lessonTitle: lesson['title'] ?? 'ملخص الدرس', summaries: lessonSummaries)));
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}