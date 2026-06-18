// lib/features/lessons/screens/courses_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/helpers/ui_helpers.dart'; // 👈 استدعاء نافذة حماية المحتوى
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart'; // 👈 استدعاء عقل الطالب
import 'package:fahem/features/lessons/presentation/screens/subject_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 👈 استدعاء البلوك
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
  void initState() {
    super.initState();
    // 👈 التعديل التأسيسي: جلب البيانات بصفة استباقية حية فور ولادة الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentCubit>().loadStudentDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 1. الترويسة العلوية ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 90, 
          automaticallyImplyLeading: false, 
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF005F61), 
                  Color(0xFF003D3F), 
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

        // ==================== 2. قائمة الكورسات المربوطة سحابياً ====================
        body: BlocBuilder<StudentCubit, StudentState>(
          builder: (context, state) {
            // أ) حالة التحميل المتناسقة (تم دمج الـ StudentInitial لمنع الوميض الأبيض نهائياً) 👈
            if (state is StudentLoading || state is StudentInitial) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF005F61),
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل مناهجك الدراسية...',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F61),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ب) حالة الخطأ
            if (state is StudentError) {
              return Center(
                child: Text(
                  state.message, 
                  style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF005F61), fontWeight: FontWeight.bold)
                )
              );
            }

            // ج) حالة الاستقرار وعرض المواد المفلترة حياً
            if (state is StudentLoaded) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(), 
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رسم قائمة المواد حياً بناءً على مصفوفة الـ Cubit المفلترة 👈
                    ListView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.subjects.length, // عدد المواد المخصصة لصف الطالب
                      itemBuilder: (context, index) {
                        final subject = state.subjects[index];
                        
                        return GestureDetector(
                          onTap: () {
                                                          // داخل الـ onTap الخاص بالكارت:
                             // داخل الـ onTap الخاص بالكارت في شاشة courses_screen.dart:
if (state.hasSubscription) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SubjectDetailsScreen(
        // 👈 ثبتنا القيم هنا يدوياً لتطابق الفايربيز 100%
        subjectId: 'sci', 
        subjectTitle: subject.title,
        studentTerm: 'الترم الثاني', 
      ),
    ),
  );
} else {
  UiHelpers.showSubscriptionPaywall(context);
}
                          },
                          child: CourseListItem(
                            title: subject.title,
                            progress: subject.progress,
                            icon: subject.icon,
                          ),
                        );
                      },
                    ),
                    
                    // مسافة أمان سفلية 
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}