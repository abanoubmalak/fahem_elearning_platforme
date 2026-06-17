// lib/features/lessons/screens/lesson_summary_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class LessonSummaryScreen extends StatelessWidget {
  final String lessonTitle;

  const LessonSummaryScreen({
    super.key,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // التزام كامل باللغة العربية
      child: Scaffold(
        // استخدمنا لون البانر كخلفية للسكافولد عشان تدويرة الكارت الأبيض تبان بنعومة
        backgroundColor: const Color(0xFF004D4F), 
        
        // ==================== 1. المحتوى الأساسي للشاشة ====================
        body: Column(
          children: [
            // ── أ. البانر العلوي (الهوية البصرية) ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF004D4F), // الفيروزي الداكن
                    Color(0xFF007A7C), // الفيروزي الفاتح
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // زر التراجع الخلفي
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withAlpha((0.15 * 255).toInt()),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                    
                    // أيقونة الملخص الكبيرة والعنوان
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.description_rounded, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'الملخص التنفيذي والسريع',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30), // مسافة قبل بداية الكارت الأبيض
                  ],
                ),
              ),
            ),

            // ── ب. النصف السفلي: كارت عرض الملخصات ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35), // حواف دائرية انسيابية
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صف عنوان الدرس
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                lessonTitle,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ),
                            const Icon(Icons.star_border_rounded, color: AppColors.primary, size: 26),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // قائمة الملخصات (المتن + الشرح)
                        _buildSummaryStructureCard(
                          originalText: 'المتن الأصلي: يتكون الجدول الدوري من 18 مجموعة رأسية و7 دورات أفقية.',
                          summaryText: 'الشرح الموجز: التقسيم الهيكلي للعناصر يعتمد على مستويات الطاقة الفرعية وعدد الإلكترونات الخارجية لتسهيل دراسة تفاعلاتها.',
                        ),
                        _buildSummaryStructureCard(
                          originalText: 'المتن الأصلي: عناصر المجموعات (1A, 2A) تمثل الفئة S وتتميز بخصائص فلزية قوية.',
                          summaryText: 'الشرح الموجز: تفقد هذه العناصر إلكترونات التكافؤ بسهولة لتكوين روابط أيونية مستقرة مع الفئات الأخرى.',
                        ),
                        _buildSummaryStructureCard(
                          originalText: 'المتن الأصلي: الغازات الخاملة تقع في المجموعة الصفرية (18) ومستوياتها الخارجية مكتملة تماماً.',
                          summaryText: 'الشرح الموجز: استقرارها الإلكتروني يمنعها من الدخول في التفاعلات الكيميائية تحت الظروف العادية.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ==================== 2. زر الإجراء السريع (آمن تماماً من الـ Overflow) ====================
        bottomNavigationBar: Container(
          color: AppColors.scaffoldBackground, // نفس لون خلفية الكارت عشان يندمج معاه
          padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                // كود الانتقال المباشر للاختبار المرتبط بالدرس لاحقاً
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6A100), // اللون الذهبي
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              label: const Text(
                'تمت المراجعة.. ابدأ الاختبار الآن',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ويدجت الكروت الهيكلية ====================
  Widget _buildSummaryStructureCard({
    required String originalText,
    required String summaryText,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).toInt()), // ظل خفيف جداً يبرز الكارت بشياكة
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            originalText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF005F61), // الفيروزي الأصلي للتطبيق
              height: 1.4,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Color(0xFFEDF2F7), thickness: 1.2),
          ),
          Text(
            summaryText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              color: AppColors.textMain,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}