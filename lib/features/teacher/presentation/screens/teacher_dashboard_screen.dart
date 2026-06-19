// lib/features/teacher/presentation/screens/tabs/teacher_subjects_tab.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_units_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_profile_screen.dart'; 
import 'package:fahem/features/teacher/presentation/cubit/teacher_cubit.dart'; // 👈 استيراد الكوبيت
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 👈 استيراد البلوك

class TeacherSubjectsTab extends StatefulWidget {
  const TeacherSubjectsTab({super.key});

  @override
  State<TeacherSubjectsTab> createState() => _TeacherSubjectsTabState();
}

class _TeacherSubjectsTabState extends State<TeacherSubjectsTab> {
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    // 👈 تغليف الشاشة بالـ BlocBuilder لقراءة البيانات الحية
    return BlocBuilder<TeacherCubit, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoading || state is TeacherInitial) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
        }
        
        if (state is TeacherError) {
          return Center(child: Text(state.message, style: const TextStyle(fontFamily: 'Cairo', color: Colors.redAccent)));
        }

        if (state is TeacherLoaded) {
          final profile = state.teacherProfile;
          final String teacherName = profile['name'] ?? 'معلم غير محدد';
          final String specialty = profile['specialty'] ?? 'غير محدد';
          final List<dynamic> assignedCourses = profile['assignedCourses'] ?? [];

          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: assignedCourses.isEmpty
                        ? const Center(child: Text('لم يتم إسناد أي مواد لك حتى الآن.', style: TextStyle(fontFamily: 'Cairo')))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                            itemCount: assignedCourses.length,
                            itemBuilder: (context, index) {
                              final course = assignedCourses[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    // داخل كارت المادة بداخل الـ ListView.builder:
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context, 
                                            Routes.TeacherUnitsScreen,
                                            // 👈 تأكد من كتابة هذا الجزء لإرسال البيانات للشاشة المستقبلة حياً
                                            arguments: {
                                              'stageName': course['stage'],
                                              'subjectId': 'sci', // الـ ID الخاص بالمادة
                                              'term': 'الترم الثاني',
                                            },
                                          );
                                        },
                                                                            child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEDF7F7), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.menu_book_rounded, color: Color(0xFF005F61), size: 24)),
                                              const SizedBox(width: 14),
                                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course['stage'] ?? 'مرحلة مجهولة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)), const SizedBox(height: 2), Text('منهج التخصص المعتمد', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]))])),
                                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                                            ],
                                          ),
                                          const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Divider(color: Color(0xFFF1F5F9), thickness: 1)),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildMiniStat(Icons.play_circle_fill_rounded, '${course['videos'] ?? 0} فيديو'),
                                              _buildMiniStat(Icons.picture_as_pdf_rounded, '${course['pdfs'] ?? 0} ملخص'),
                                              _buildMiniStat(Icons.assignment_rounded, '${course['quizzes'] ?? 0} اختبار', color: const Color(0xFFE6A100)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  Positioned(
                    top: 0, left: 0, right: 0, height: headerHeight,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('مرحباً، $teacherName 👋', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  IconButton(
                                    icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                                    onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => const TeacherProfileScreen())),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                                child: Text('تخصصك المعتمد: $specialty', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))),
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
        return const SizedBox();
      },
    );
  }

  Widget _buildMiniStat(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color ?? Colors.grey[700], fontWeight: FontWeight.bold)),
      ],
    );
  }
}