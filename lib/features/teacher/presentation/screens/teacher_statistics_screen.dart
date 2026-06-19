// lib/features/teacher/presentation/screens/dashboard/teacher_statistics_screen.dart
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
          final int totalStudents = profile['totalStudents'] ?? 0;
          final double averageScore = (profile['averageScore'] ?? 0.0).toDouble();

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
                          const Text('نظرة عامة على نشاطك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(title: 'إجمالي الطلاب', value: '$totalStudents', icon: Icons.groups_rounded, color: const Color(0xFF005F61))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard(title: 'متوسط تفاعل الطلبة', value: '${averageScore.toStringAsFixed(1)}%', icon: Icons.insights_rounded, color: const Color(0xFFE6A100))),
                            ],
                          ),
                          const SizedBox(height: 35),
                          const Text('مستوى فهم واستيعاب الطلاب', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                            child: Column(
                              children: [
                                _buildPerformanceBar(label: 'ممتاز (أكبر من 85%)', percentage: 0.65, color: const Color(0xFF27AE60), count: (totalStudents * 0.65).toInt()),
                                const SizedBox(height: 18),
                                _buildPerformanceBar(label: 'جيد جداً (75% - 85%)', percentage: 0.25, color: const Color(0xFF005F61), count: (totalStudents * 0.25).toInt()),
                                const SizedBox(height: 18),
                                _buildPerformanceBar(label: 'يحتاج متابعة (أقل من 50%)', percentage: 0.10, color: Colors.redAccent, count: (totalStudents * 0.10).toInt()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0, height: headerHeight - 20,
                    child: Container(
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                      child: const SafeArea(child: Center(child: Text('الإحصائيات والتقارير', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 👈 هذا الكود يوضع كبديل لـ return const SizedBox(); 
        if (state is TeacherLoading || state is TeacherInitial) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(child: CircularProgressIndicator(color: Color(0xFF005F61))),
          );
        }
        if (state is TeacherError) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(
              child: Text(
                state.message, 
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).toInt()), shape: BoxShape.circle), child: Icon(icon, color: color, size: 26)),
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
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: percentage, backgroundColor: const Color(0xFFF1F5F9), valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8)),
      ],
    );
  }
}