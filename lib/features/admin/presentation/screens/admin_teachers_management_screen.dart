// lib/features/admin/presentation/screens/teachers/admin_teachers_management_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

class AdminTeachersManagementScreen extends StatefulWidget {
  const AdminTeachersManagementScreen({super.key});

  @override
  State<AdminTeachersManagementScreen> createState() => _AdminTeachersManagementScreenState();
}

class _AdminTeachersManagementScreenState extends State<AdminTeachersManagementScreen> {
  // ── بيانات محاكاة (Mock Data) مؤقتة لحين الربط بالـ API ──
  final List<Map<String, dynamic>> _teachersList = [
    {
      'id': '1',
      'name': 'أحمد محمود',
      'email': 'ahmed@fahem.com',
      'main_subject': 'رياضيات - إعدادي',
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'سارة إبراهيم',
      'email': 'sara@fahem.com',
      'main_subject': 'لغة إنجليزية - ابتدائي',
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'يوسف خالد',
      'email': 'youssef@fahem.com',
      'main_subject': 'علوم - إعدادي',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // توحيد ارتفاع الهيدر ليتناسب مع باقي الشاشات
    final double headerHeight = MediaQuery.of(context).size.height * 0.16;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // زر إضافة معلم جديد
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // التوجيه لشاشة إضافة المعلم اللي أنت برمجتها
          Navigator.pushNamed(context, Routes.AddTeacherScreen);
        },
        backgroundColor: const Color(0xFF005F61),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'إضافة معلم',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ── قائمة المعلمين ──
            Positioned.fill(
              child: _teachersList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100), // padding سفلي عشان الـ FAB
                      itemCount: _teachersList.length,
                      itemBuilder: (context, index) {
                        final teacher = _teachersList[index];
                        return _buildTeacherCard(teacher);
                      },
                    ),
            ),

            // ── الهيدر الموحد ──
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(30),
                  //   bottomRight: Radius.circular(30),
                  // ),
                ),
                child: const SafeArea(
                  child: Center(
                    child: Text(
                      'إدارة المعلمين',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  // ── كارت عرض بيانات المعلم ──
  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: التوجيه لشاشة تفاصيل المعلم (التي تحتوي على زري التعديل والحذف)
            Navigator.pushNamed(context, Routes.TeacherDetailsScreen);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('جاري الانتقال لشاشة التفاصيل...', style: TextStyle(fontFamily: 'Cairo'))),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // الصورة الرمزية
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFEDF7F7),
                  child: Text(
                    teacher['name'].substring(0, 1),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005F61),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // تفاصيل المعلم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher['name'],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              teacher['main_subject'],
                              style: TextStyle(
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
                // حالة الحساب وسهم الدخول
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    
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

  // ── شاشة فارغة في حالة عدم وجود معلمين ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا يوجد معلمون مضافين بعد',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}