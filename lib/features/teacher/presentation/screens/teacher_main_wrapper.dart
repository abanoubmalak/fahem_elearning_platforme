// lib/features/teacher/presentation/screens/teacher_main_wrapper.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/app_router.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_profits_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_questions_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_statistics_screen.dart';
import 'package:flutter/material.dart';

// استيراد الشاشات الأربعة (سنقوم بإنشائها وتطويرها واحدة تلو الأخرى بناءً على طلبك)
// ملاحظة: قمت بإنشاء ويدجت مؤقتة (Placeholders) أسفل هذا الملف لكي يعمل الكود معك فوراً بدون أخطاء.

class TeacherMainWrapper extends StatefulWidget {
  const TeacherMainWrapper({super.key});

  @override
  State<TeacherMainWrapper> createState() => _TeacherMainWrapperState();
}

class _TeacherMainWrapperState extends State<TeacherMainWrapper> {
  // المؤشر الحالي للقسم النشط في شريط التنقل السفلي (البداية من قسم المواد)
  int _currentTabIndex = 0;

  // قائمة الصفحات الأربعة الخاصة بنافذة المعلم
  final List<Widget> _tabs = [
     const TeacherSubjectsTab(),   // 1. قسم المواد وإدارة المحتوى
     const TeacherQuestionsScreen(),  // 2. قسم الأسئلة وصندوق رسائل الطلاب
     const TeacherStatisticsScreen(),  // 3. قسم الإحصائيات والتقارير التعليمية
    const TeacherFinancialScreen(),   // 4. قسم الأرباح والمحفظة المالية
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      
      // جسم الشاشة يتغير ديناميكياً بناءً على التبويب المختار مع الحفاظ على حالة الصفحات (IndexedStack)
      body: Directionality(
        textDirection: TextDirection.rtl, // ضبط لغة التطبيق من اليمين لليسار
        child: IndexedStack(
          index: _currentTabIndex,
          children: _tabs,
        ),
      ),

      // ==================== شريط التنقل السفلي الفاخر للمعلم (Bottom Navigation Bar) ====================
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).toInt()),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed, // ثبات الأيقونات وتوزيع المساحات هندسياً
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF005F61), // اللون الفيروزي المعتمد للتنشيط
            unselectedItemColor: Colors.grey[400], // لون الأيقونات غير النشطة
            selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_stories_outlined,size: 30),
                activeIcon: Icon(Icons.auto_stories_rounded,size: 30),
                label: 'موادي',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded,size: 30),
                activeIcon: Icon(Icons.chat_bubble_rounded,size: 30),
                label: 'الأسئلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined,size: 30),
                activeIcon: Icon(Icons.analytics_rounded,size: 30),
                label: 'الإحصائيات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined,size: 30),
                activeIcon: Icon(Icons.account_balance_wallet_rounded,size: 30),
                label: 'الأرباح',
              ),
            ],
          ),
        ),
      ),
    );
  }
}