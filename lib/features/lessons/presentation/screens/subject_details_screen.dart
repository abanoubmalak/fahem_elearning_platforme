// lib/features/lessons/screens/subject_details_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/lessons/presentation/screens/lessom_summery_screen.dart';
import 'package:fahem/features/lessons/presentation/widgets/video_player_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/unit_expansion_tile.dart';
import '../widgets/lesson_list_item.dart';
import 'quiz_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // توجيه التطبيق للغة العربية
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 1. الترويسة العلوية المنحنية (AppBar) ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 85, // مساحة مريحة للعنوان
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF005F61), // الفيروزي المميز
                  Color(0xFF003D3F),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'المحتوى الدراسي',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),

        // ==================== 2. محتوى الصفحة القابل للتمرير ====================
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // سكرول انسيابي
          padding: const EdgeInsets.symmetric(vertical: 24), // مسافات علوية وسفلية مريحة
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== كارت معلومات المادة العائم ====================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.04 * 255).toInt()),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // أيقونة المادة الجذابة
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.science_rounded,
                        color: Color(0xFF005F61),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // اسم المادة
                    const Expanded(
                      child: Text(
                        'تفاصيل مادة: الكيمياء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================== 3. قائمة الوحدات والدروس ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الوحدة الأولى
                    UnitExpansionTile(
                      title: 'الوحدة الأولى: الأساسيات الكيميائية',
                      initiallyExpanded: true,
                      lessons: [
                        LessonListItem(
                          title: 'الدرس الأول: الجدول الدوري ',
                          isCompleted: true,
                          onWatchVideo: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VideoPlayerScreen(lessonTitle: 'الدرس الأول: الجدول'),
                              ),
                            );
                          },
                          onTakeQuiz: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizScreen(lessonTitle: 'اختبار: الجدول الدوري '),
                              ),
                            );
                          },
                          onViewSummary: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LessonSummaryScreen(lessonTitle: 'ملخص: الجدول الدوري '),
                              ),
                            );
                          },
                        ),
                        LessonListItem(
                          title: 'الدرس الثاني: الروابط ',
                          isCompleted: false,
                          onWatchVideo: () {},
                          onTakeQuiz: () {},
                          onViewSummary: () {},
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),

                    // الوحدة الثانية
                    UnitExpansionTile(
                      title: 'الوحدة الثانية: مركبات الحديد ',
                      lessons: [
                        LessonListItem(
                          title: 'الدرس الثالث: تفاعلات الأكسدة',
                          isCompleted: false,
                          onWatchVideo: () {},
                          onTakeQuiz: () {},
                          onViewSummary: () {},
                        ),
                        LessonListItem(
                          title: 'الدرس الرابع: سبائك الحديد',
                          isCompleted: false,
                          onWatchVideo: () {},
                          onTakeQuiz: () {},
                          onViewSummary: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // باقي الوحدات
                    const UnitExpansionTile(title: 'الوحدة الثالثة: الكيمياء العضوية', lessons: []),
                    const SizedBox(height: 16),
                    const UnitExpansionTile(title: 'الوحدة الرابعة: الكيمياء الكهربية', lessons: []),
                    
                    // مسافة أمان سفلية مريحة للتمرير
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}