// lib/features/teacher/presentation/screens/dashboard/teacher_statistics_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

class TeacherStatisticsScreen extends StatefulWidget {
  const TeacherStatisticsScreen({super.key});

  @override
  State<TeacherStatisticsScreen> createState() => _TeacherStatisticsScreenState();
}

class _TeacherStatisticsScreenState extends State<TeacherStatisticsScreen> {
  // ==================== محاكاة بيانات الإحصائيات (Mock Data) ====================
  final int _totalStudents = 1240;
  final double _averageScore = 86.5;

  @override
  Widget build(BuildContext context) {
    // 💎 توحيد الحسبة للارتفاع هندسياً بشكل منسق تماماً لمنع أي فجوات أو تفاوت في الأبعاد 💎
    final double headerHeight = MediaQuery.of(context).size.height * 0.18;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. محتوى الإحصائيات (في الخلفية أولاً) ====================
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- القسم الأول: كروت الملخص السريع (محدثة لتناسب عنصرين بشكل متزن وفخم) ---
                    const Text('نظرة عامة على النشاط', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'إجمالي الطلاب المشتركين', 
                            value: '$_totalStudents', 
                            icon: Icons.groups_rounded, 
                            color: const Color(0xFF005F61),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: 'متوسط درجات الاختبارات', 
                            value: '$_averageScore%', 
                            icon: Icons.analytics_rounded, 
                            color: const Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- القسم الثاني: مؤشرات الأداء الأكاديمي ---
                    const Text('تحليل مستويات الطلاب (آخر اختبار)', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _buildPerformanceBar(label: 'ممتاز (85% - 100%)', percentage: 0.65, color: const Color(0xFF27AE60), count: 806),
                          const SizedBox(height: 16),
                          _buildPerformanceBar(label: 'جيد (65% - 84%)', percentage: 0.25, color: const Color(0xFFE6A100), count: 310),
                          const SizedBox(height: 16),
                          _buildPerformanceBar(label: 'بحاجة لدعم (أقل من 65%)', percentage: 0.10, color: Colors.redAccent, count: 124),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================== 2. البانر الفيروزي العلوي (في المقدمة آخراً) ====================
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-20,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)], 
                    begin: Alignment.topRight, 
                    end: Alignment.bottomLeft,
                  ),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        
                        // IconButton(
                        //   icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        //   onPressed: () => Navigator.pushNamed(context, Routes.TeacherMainWrapper), 
                        // ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('التقارير والإحصائيات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('متابعة أداء الطلاب ومستوى التحصيل', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)),
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
  }

  // ==================== دوال بناء واجهة المستخدم المحسنة بصرياً ====================

  // دالة بناء الكروت المحسنة (إعطاء الكروت عمقاً رأسياً أطول وأيقونة دائرية لملء المساحة بشكل فخم)
  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha((0.08 * 255).toInt()), 
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPerformanceBar({required String label, required double percentage, required Color color, required int count}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            Text('$count طالب', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}