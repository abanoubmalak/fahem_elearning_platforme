// lib/features/admin/presentation/screens/admin_dashboard_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fahem/core/routing/routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💎 توحيد أبعاد الترويسة 💎
    final double headerHeight = MediaQuery.of(context).size.height * 0.18;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        // متغيرات لاستقبال البيانات الحية
        int teachersCount = 0;
        int studentsCount = 0;
        int parentsCount = 0;
        double platformEarnings = 0.0;
        double teachersEarnings = 0.0;

        if (state is AdminLoaded) {
          teachersCount = state.teachers.length;
          studentsCount = state.students.length;
          parentsCount = state.parents.length; // تأكد من أن الـ Cubit يحتوي على أولياء الأمور
          platformEarnings = (state.financials['platformNetEarnings'] ?? 0.0).toDouble();
          teachersEarnings = (state.financials['totalTeachersHolding'] ?? 0.0).toDouble();
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                // ==================== 1. المحتوى (الإحصائيات الحية) ====================
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نظرة عامة على نشاط المنصة', 
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)
                        ),
                        const SizedBox(height: 20),

                        // 💎 كارت أرباح المنصة الرئيسي (Full Width) 💎
                        _buildMainEarningsCard(platformEarnings),
                        const SizedBox(height: 16),
                        
                        // 💎 الإحصائيات الفرعية (2x2 Grid) 💎
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('إجمالي الطلاب', studentsCount.toString(), Icons.groups_rounded, const Color(0xFF27AE60), const Color(0xFFEAFAF1))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('إجمالي المعلمين', teachersCount.toString(), Icons.school_rounded, const Color(0xFF005F61), const Color(0xFFEDF7F7))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('أولياء الأمور', parentsCount.toString(), Icons.family_restroom_rounded, const Color(0xFF8E44AD), const Color(0xFFF4ECF7))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('أرباح المعلمين', '${teachersEarnings.toStringAsFixed(0)} ج.م', Icons.payments_rounded, const Color(0xFFE6A100), const Color(0xFFFEF6E5))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================== 2. البانر العلوي الفيروزي ====================
                Positioned(
                  top: 0, left: 0, right: 0, height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    ),
                    child: SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [

        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 22,
            ),
            tooltip: 'تسجيل الخروج',
          ),
        ),

        const Spacer(),

        const Text(
          'لوحة تحكم الإدارة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const Spacer(),

        const SizedBox(width: 48), // للمحافظة على التوسيط
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
      },
    );
  }

  // =========================================================
  // 🎨 تصميمات الكروت الجمالية
  // =========================================================




void _logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج من حساب الإدارة؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
            ),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              await FirebaseAuth.instance.signOut();

              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                (route) => false,
              );
            },
            child: const Text(
              'خروج',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  // 1. الكارت الرئيسي لأرباح المنصة (تصميم مميز)
  Widget _buildMainEarningsCard(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005F61), Color(0xFF00898C)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF005F61).withAlpha((0.3 * 255).toInt()), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('صافي أرباح المنصة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${amount.toStringAsFixed(0)} ج.م',
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 2. الكروت الفرعية المربعة
  Widget _buildStatCard(String title, String value, IconData icon, Color mainColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: mainColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}