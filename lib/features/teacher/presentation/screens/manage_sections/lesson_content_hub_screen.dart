// lib/features/teacher/presentation/screens/manage_sections/lesson_content_hub_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

// استيراد شاشات الإدارة المنفصلة الأكاديمية
import 'manage_media_content_screen.dart';
import 'manage_text_summary_screen.dart';
import 'manage_quiz_content_screen.dart';

class LessonContentHubScreen extends StatefulWidget {
  final String lessonName;
  const LessonContentHubScreen({super.key, required this.lessonName});

  @override
  State<LessonContentHubScreen> createState() => _LessonContentHubScreenState();
}

class _LessonContentHubScreenState extends State<LessonContentHubScreen> {
  // محاكاة لحالة البيانات في السيرفر (لتحديث الواجهة حياً)
  bool _hasVideo = true;    // فرضاً الفيديو مضاف
  bool _hasSummary = false; // فرضاً الملخص غير مضاف
  bool _hasQuiz = true;     // فرضاً الاختبار مضاف

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. كروت التوجيه الذكية (في الخلفية أولاً) ====================
            // 💎 نقلنا الـ Scroll ليكون أول طبقة في الـ Stack لكي لا يحجب أزرار الترويسة 💎
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight , 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('اختر القسم المطلوب إدارته:', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 16),

                    // 1️⃣ كارت التوجيه لشاشة (الفيديو)
                    _buildHubCard(
                      title: 'فيديو الشرح',
                      subtitle: 'رفع، تعديل، أو حذف فيديو الدرس',
                      icon: Icons.play_circle_fill_rounded,
                      iconBgColor: const Color(0xFFEDF7F7),
                      iconColor: const Color(0xFF005F61),
                      isAdded: _hasVideo,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.ManageMediaContentScreen).then((_) {
                          setState(() {}); 
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // 2️⃣ كارت التوجيه لشاشة (الملخص النصي)
                    _buildHubCard(
                      title: 'الملخص والمذكرة',
                      subtitle: 'كتابة وتحديث الملخص الأكاديمي للدرس',
                      icon: Icons.article_rounded,
                      iconBgColor: const Color(0xFFE8F8F5),
                      iconColor: const Color(0xFF27AE60),
                      isAdded: _hasSummary,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.ManageTextSummaryScreen).then((_) {
                          setState(() {});
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // 3️⃣ كارت التوجيه لشاشة (الامتحان MCQ)
                    _buildHubCard(
                      title: 'اختبار الاستيعاب (MCQ)',
                      subtitle: 'إضافة وتعديل أسئلة واختيارات الامتحان',
                      icon: Icons.assignment_turned_in_rounded,
                      iconBgColor: const Color(0xFFFEF6E5),
                      iconColor: const Color(0xFFE6A100),
                      isAdded: _hasQuiz,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.ManageQuizContentScreen).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==================== 2. الترويسة العلوية الفخمة (في المقدمة آخراً) ====================
            // 💎 تم نقلها إلى نهاية الـ Stack لتطفو على السطح وتستجيب اللمسات مباشرة 💎
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pushNamed(context, Routes.TeacherLessonsScreen) // سيعمل بكفاءة مطلقة الآن وينقلك للشاشة السابقة
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('إدارة محتويات الدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.lessonName,
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
  }

  // باني الكروت المحمية من الـ Overflow
  Widget _buildHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isAdded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isAdded ? iconColor.withAlpha((0.3 * 255).toInt()) : Colors.grey[200]!, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 28),
            ),
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
                    decoration: BoxDecoration(
                      color: isAdded ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAdded ? 'متوفر ومضاف ✔' : 'غير مضاف ✖',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: isAdded ? const Color(0xFF27AE60) : Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF005F61)),
            ),
          ],
        ),
      ),
    );
  }
}