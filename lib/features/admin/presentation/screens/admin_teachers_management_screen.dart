// lib/features/admin/presentation/screens/teachers/admin_teachers_management_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminTeachersManagementScreen extends StatefulWidget {
  const AdminTeachersManagementScreen({super.key});

  @override
  State<AdminTeachersManagementScreen> createState() => _AdminTeachersManagementScreenState();
}

class _AdminTeachersManagementScreenState extends State<AdminTeachersManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.16;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "fab_teachers_management_unique", // 👈 تأمين الهيرو تاغ من التضارب
        onPressed: () => Navigator.pushNamed(context, Routes.AddTeacherScreen),
        backgroundColor: const Color(0xFF005F61),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة معلم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            List<Map<String, dynamic>> teachers = [];
            if (state is AdminLoaded) {
              teachers = state.teachers; // 👈 القراءة الحية المباشرة من الفايربيز
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: teachers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            return _buildTeacherCard(teachers[index]);
                          },
                        ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0, height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                    ),
                    child: const SafeArea(
                      child: Center(
                        child: Text('إدارة المعلمين', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final bool isActive = teacher['isActive'] ?? true;
     

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // 💎 تمرير مصفوفة بيانات المعلم الحية كـ Arguments لمنع الشاشة البيضاء والتجميد 💎
            Navigator.pushNamed(context, Routes.TeacherDetailsScreen, arguments: teacher);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26, backgroundColor: const Color(0xFFEDF7F7),
                  child: Text((teacher['name'] ?? 'م').substring(0, 1), style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacher['name'] ?? 'بدون اسم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                          child: Text(teacher['specialty'] ?? 'لم تحدد المادة بعد',style: TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    color: Colors.grey.shade600,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.circle, size: 8, color: isActive ? const Color(0xFF27AE60) : Colors.grey),
                    const SizedBox(height: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), const Text('لا يوجد معلمون مضافين بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold))]));
  }
}