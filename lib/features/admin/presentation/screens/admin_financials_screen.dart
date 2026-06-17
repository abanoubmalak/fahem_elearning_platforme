// lib/features/admin/presentation/screens/admin_treasury_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class AdminTreasuryScreen extends StatefulWidget {
  const AdminTreasuryScreen({super.key});

  @override
  State<AdminTreasuryScreen> createState() => _AdminTreasuryScreenState();
}

class _AdminTreasuryScreenState extends State<AdminTreasuryScreen> {
  // ==================== 1. بيانات الخزينة المركزية ====================
  double _platformNetEarnings = 8450.0;     
  double _teachersHoldingFunds = 14200.0;   
  
  final List<Map<String, dynamic>> _pendingRequests = [
    {'id': 'TR-101', 'teacher': 'أ. رأفت حكيم', 'subject': 'الرياضيات', 'amount': 1200.0, 'method': 'فودافون كاش (01012345678)', 'date': 'اليوم، 11:00 ص'},
    {'id': 'TR-102', 'teacher': 'أ. ميرفت علي', 'subject': 'العلوم', 'amount': 2400.0, 'method': 'تحويل بنكي (EG123...)', 'date': 'أمس، 04:30 م'},
    {'id': 'TR-103', 'teacher': 'أ. محمد أحمد', 'subject': 'اللغة العربية', 'amount': 850.0, 'method': 'فودافون كاش (0119876...)', 'date': '15 يونيو، 01:15 م'},
  ];

  // ==================== 2. منطق الموافقة على السحب ====================
  void _approvePayout(int index) {
    final request = _pendingRequests[index];
    final double amount = request['amount'];
    final String teacherName = request['teacher'];

    setState(() {
      _teachersHoldingFunds -= amount;
      _pendingRequests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت الموافقة وتصفية مبلغ ${amount.toStringAsFixed(0)} ج.م لصالح $teacherName بنجاح 💸', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF005F61),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 3. الترويسة العلوية ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          //   onPressed: () => Navigator.pop(context),
          // ),
          title: const Text(
            'الخزينة المركزية وإدارة السحب',
            style: TextStyle(
              fontFamily: 'Cairo', 
              fontSize: 16, // تم تصغير الخط ليتناسب مع الشاشات الصغيرة دون قطع
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ),
          centerTitle: true,
        ),

        // ==================== 4. المعمارية الهندسية ====================
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أ) كروت تقارير الخزينة
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTreasuryCard(
                      title: 'أرباح المنصة الصافية', // تقصير النص للوضوح
                      amount: _platformNetEarnings,
                      icon: Icons.account_balance_rounded,
                      mainColor: const Color(0xFF005F61),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTreasuryCard(
                      title: 'مستحقات المعلمين', // تقصير النص للوضوح
                      amount: _teachersHoldingFunds,
                      icon: Icons.lock_clock_rounded,
                      mainColor: const Color(0xFFE6A100),
                    ),
                  ),
                ],
              ),
            ),

            // عنوان قائمة الطلبات محمي بـ Expanded لمنع Overflow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'طلبات السحب المعلقة للتحويل',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _pendingRequests.isEmpty ? Colors.grey.shade200 : const Color(0xFFFFEAEA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_pendingRequests.length} طلبات معلقة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _pendingRequests.isEmpty ? Colors.grey : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ب) قائمة طلبات السحب
            Expanded(
              child: _pendingRequests.isEmpty
                  ? _buildEmptyStateWidget()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 30),
                      itemCount: _pendingRequests.length,
                      itemBuilder: (context, index) {
                        final request = _pendingRequests[index];
                        return _buildPayoutRequestCard(request, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 5. مكونات بناء الواجهة ====================

  Widget _buildTreasuryCard({required String title, required double amount, required IconData icon, required Color mainColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18), // تقليل الـ padding العرضي
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // الحفاظ على المحاذاة مع السماح بسطرين
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: mainColor.withAlpha((0.1 * 255).toInt()),
            child: Icon(icon, color: mainColor, size: 18),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36, // تثبيت الارتفاع لضمان تساوي الكروت حتى لو أحدها سطر والآخر سطرين
            child: Text(
              title,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600, height: 1.4),
              maxLines: 2, // السماح بنزول النص لسطر جديد
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} ج.م',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w900, color: mainColor), // تصغير طفيف للرقم
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutRequestCard(Map<String, dynamic> request, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFEDF7F7),
                child: Icon(Icons.person_outline_rounded, color: Color(0xFF005F61), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['teacher'],
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'معلم مادة: ${request['subject']}',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${request['amount'].toStringAsFixed(0)} ج.م',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),

          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'طريقة الاستلام: ${request['method']}',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'وقت الطلب: ${request['date']}',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _approvePayout(index),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
              label: const Text('الموافقة وإتمام التحويل المالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, color: const Color(0xFF2ECC71).withAlpha((0.2 * 255).toInt()), size: 70),
          const SizedBox(height: 16),
          const Text(
            'ممتاز! تم تسوية ومراجعة كافة\nطلبات سحب المعلمين بنجاح.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}