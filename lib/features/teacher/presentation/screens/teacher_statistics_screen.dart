import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherStatisticsScreen extends StatefulWidget {
  const TeacherStatisticsScreen({super.key});

  @override
  State<TeacherStatisticsScreen> createState() => _TeacherStatisticsScreenState();
}

class _TeacherStatisticsScreenState extends State<TeacherStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.18;

    return BlocBuilder<TeacherCubit, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoaded) {
          final profile = state.teacherProfile;
          final int totalStudents = (profile['totalStudents'] ?? 0).toInt();
          final List<dynamic> assignedCourses = profile['assignedCourses'] ?? [];

          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('بيانات المدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 20),
                          
                          _buildStatCard(
                            title: 'إجمالي الطلاب', 
                            value: '$totalStudents', 
                            icon: Icons.groups_rounded, 
                            color: const Color(0xFF005F61)
                          ),
                          
                          const SizedBox(height: 30),
                          const Text('المواد والدورات المسندة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 16),
                          
                          // عرض قائمة الكورسات
                          assignedCourses.isEmpty 
                            ? const Text('لا توجد مواد مسندة حالياً', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: assignedCourses.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final course = assignedCourses[index];
                                  return _buildCourseCard(course);
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0, height: headerHeight - 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF005F61), Color(0xFF003D3F)], 
                          begin: Alignment.topRight, 
                          end: Alignment.bottomLeft
                        )
                      ),
                      child: const SafeArea(
                        child: Center(
                          child: Text('الإحصائيات والتقارير', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TeacherLoading || state is TeacherInitial) {
          return const Scaffold(backgroundColor: AppColors.scaffoldBackground, body: Center(child: CircularProgressIndicator(color: Color(0xFF005F61))));
        }
        
        if (state is TeacherError) {
          return Scaffold(backgroundColor: AppColors.scaffoldBackground, body: Center(child: Text(state.message, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16))));
        }

        return const SizedBox();
      },
    );
  }

  // بطاقة عرض تفاصيل المادة
  Widget _buildCourseCard(dynamic course) {
    String subjectName = course['subject'].toString() == 'sci' ? 'العلوم' : (course['subject'] ?? 'غير محدد');
    String stage = course['stage'] ?? '';
    String term = course['term'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 5, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFF005F61).withAlpha((0.1 * 255).toInt()))
      ),
      child: Row(
        children: [
          const Icon(Icons.book_rounded, color: Color(0xFF005F61), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subjectName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(5)), child: Text(stage, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey))),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(5)), child: Text(term, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة إجمالي الطلاب
  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle), 
            child: Icon(icon, color: color, size: 26)
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}