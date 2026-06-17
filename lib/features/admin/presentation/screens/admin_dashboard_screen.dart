// lib/features/admin/presentation/screens/dashboard/admin_dashboard_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💎 توحيد أبعاد الترويسة 💎
    final double headerHeight = MediaQuery.of(context).size.height * 0.18;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. المحتوى (في الخلفية أولاً) ====================
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('لوحة التحكم - نظرة عامة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    const SizedBox(height: 20),
                    
                    // صف الإحصائيات (4 كروت: 2x2)
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('إجمالي المعلمين', '45', Icons.school_rounded, const Color(0xFF005F61))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('إجمالي الطلاب', '1,240', Icons.groups_rounded, const Color(0xFF27AE60))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('الأرباح الكلية', '85.2k', Icons.payments_rounded, const Color(0xFFE6A100))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('طلبات سحب معلقة', '12', Icons.account_balance_wallet_rounded, Colors.redAccent)),
                      ],
                    ),

                    const SizedBox(height: 35),
                    const Text('طلبات سحب الأرباح', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    const SizedBox(height: 12),
                    
                    // قائمة طلبات السحب
                    _buildWithdrawalRequest('أحمد محمود', '2,500 ج.م', 'فودافون كاش'),
                    _buildWithdrawalRequest('سارة إبراهيم', '1,200 ج.م', 'تحويل بنكي'),
                    _buildWithdrawalRequest('يوسف خالد', '450 ج.م', 'فودافون كاش'),
                  ],
                ),
              ),
            ),

            // ==================== 2. البانر الفيروزي (في المقدمة) ====================
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: const SafeArea(
                  child: Center(
                    child: Text('لوحة تحكم الأدمن', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // كارت إحصائية
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // عنصر طلب سحب أرباح
  Widget _buildWithdrawalRequest(String name, String amount, String method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFFEF6E5), child: Icon(Icons.wallet_rounded, color: Color(0xFFE6A100))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                Text('$amount • $method', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle, color: Color(0xFF27AE60))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.cancel, color: Colors.redAccent)),
        ],
      ),
    );
  }
}