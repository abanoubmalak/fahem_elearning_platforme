// lib/features/lessons/screens/courses_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/lessons/presentation/screens/subject_details_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/course_list_item.dart';
class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<Courses> {
  // تفعيل الزر رقم 2 في شريط التنقل السفلي (أيقونة دوراتي)
  final int _currentIndex = 2; 

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // ضبط المحتوى العربي من اليمين لليسار
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 1. الترويسة العلوية (AppBar محمي من الـ Overflow) ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 90, // ارتفاع مريح للترويسة لتستوعب النص والوصف
          automaticallyImplyLeading: false, // إلغاء زر الرجوع التلقائي لأنها شاشة رئيسية
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF005F61), // الفيروزي
                  Color(0xFF003D3F), // الفيروزي الداكن
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'دوراتي الدراسيّة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'تابع تقدمك في المواد والمناهج العلمية أولاً بأول',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // ==================== 2. قائمة الكورسات ====================
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // حركة سكرول مرنة وانسيابية (iOS Style)
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض قائمة الكورسات العمودية باستقرار تام
              ListView(
                shrinkWrap: true, // يمنع تعارض أبعاد الارتفاع البرمجية
                physics: const NeverScrollableScrollPhysics(), // تفويض السكرول للـ SingleChildScrollView
                // 👈 تم إزالة الـ const من هنا عشان نسمح بإضافة دوال التوجيه
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()),
                      );
                    },
                    child: const CourseListItem(
                      title: 'اللغة العربية',
                      progress: 0.70,
                      icon: Icons.menu_book_rounded,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()),
                      );
                    },
                    child: const CourseListItem(
                      title: 'اللغة الانجليزية',
                      progress: 0.45,
                      icon: Icons.menu_book_rounded,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()),
                      );
                    },
                    child: const CourseListItem(
                      title: 'الرياضيات',
                      progress: 0.90,
                      icon: Icons.calculate_rounded,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()),
                      );
                    },
                    child: const CourseListItem(
                      title: 'العلوم',
                      progress: 1.0, // كورس مكتمل
                      icon: Icons.science_rounded,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()),
                      );
                    },
                    child: const CourseListItem(
                      title: 'الدراسات الاجتماعية',
                      progress: 1.0, // كورس مكتمل
                      icon: Icons.public_rounded,
                    ),
                  ),
                ],
              ),
              
              // مسافة أمان سفلية مريحة لمنع حجب الكارت الأخير خلف شريط التنقل السفلي للتطبيق
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}