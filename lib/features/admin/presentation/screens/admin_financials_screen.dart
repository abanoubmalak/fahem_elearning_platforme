// lib/features/admin/presentation/screens/admin_financials_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminTreasuryScreen extends StatefulWidget {
  const AdminTreasuryScreen({super.key});

  @override
  State<AdminTreasuryScreen> createState() => _AdminTreasuryScreenState();
}

class _AdminTreasuryScreenState extends State<AdminTreasuryScreen> {
  
  // ── 1. دالة تنفيذ سحب أرباح المنصة ──
  void _withdrawPlatformEarnings(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل سحب مبلغ ${amount.toStringAsFixed(0)} ج.م بنجاح 💸', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
    // TODO: تحديث الرصيد في الفايربيز هنا
  }

  // ── 2. نافذة تحديد مبلغ السحب ──
  void _showWithdrawDialog(double maxAmount) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.account_balance_rounded, color: Color(0xFF005F61)),
              SizedBox(width: 8),
              Text('سحب أرباح المنصة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الرصيد القابل للسحب: ${maxAmount.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'المبلغ المراد سحبه',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF005F61)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF005F61), width: 2)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final double? amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                  return;
                }
                if (amount > maxAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المبلغ المطلوب يتجاوز الرصيد المتاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                  return;
                }
                Navigator.pop(ctx);
                _withdrawPlatformEarnings(amount);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('تأكيد السحب', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.16;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        double platformNetEarnings = 0.0;
        double teachersHoldingFunds = 0.0;
        List<Map<String, dynamic>> pendingRequests = [];

        if (state is AdminLoaded) {
          platformNetEarnings = (state.financials['platformNetEarnings'] ?? 0.0).toDouble();
          teachersHoldingFunds = (state.financials['totalTeachersHolding'] ?? 0.0).toDouble();
          pendingRequests = List.from(state.payoutRequests);
        }

        // 💎 إضافة بيانات محاكاة مؤقتة لمعاينة التصميم في حالة عدم وجود طلبات حقيقية 💎
        if (pendingRequests.isEmpty) {
          pendingRequests = [
            {'id': 'REQ-001', 'teacher': 'أ. أحمد محمود', 'subject': 'الرياضيات', 'amount': 1500.0, 'teacherId': '1'},
            {'id': 'REQ-002', 'teacher': 'أ. سارة إبراهيم', 'subject': 'اللغة الإنجليزية', 'amount': 850.0, 'teacherId': '2'},
            {'id': 'REQ-003', 'teacher': 'أ. يوسف خالد', 'subject': 'العلوم', 'amount': 3200.0, 'teacherId': '3'},
          ];
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // ==================== 1. كارت أرباح المنصة + زر السحب ====================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF005F61), Color(0xFF00898C)], begin: Alignment.bottomRight, end: Alignment.topLeft),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: const Color(0xFF005F61).withAlpha((0.3 * 255).toInt()), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('أرباح المنصة الصافية', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${platformNetEarnings.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 20),
                              
                              // زر استدعاء نافذة السحب
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showWithdrawDialog(platformNetEarnings),
                                  icon: const Icon(Icons.download_rounded, color: Color(0xFF005F61)),
                                  label: const Text('سحب أرباح المنصة', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ==================== 2. كارت مستحقات المعلمين (تم حل مشكلة الـ Overflow هنا) ====================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 💎 تغليف النص بـ Expanded لمنع التمدد خارج الشاشة 💎
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('إجمالي مستحقات المعلمين', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('${teachersHoldingFunds.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(color: Color(0xFFFEF6E5), shape: BoxShape.circle), child: const Icon(Icons.wallet_rounded, color: Color(0xFFE6A100), size: 28)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),
                        
                        // ==================== 3. قسم طلبات السحب ====================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('طلبات سحب المعلمين', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                            if (pendingRequests.isNotEmpty)
                              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(10)), child: Text('${pendingRequests.length} طلبات معلقة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent))),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // قائمة الطلبات
                        if (pendingRequests.isEmpty)
                          _buildEmptyStateWidget()
                        else
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              final request = pendingRequests[index];
                              return _buildSimplifiedPayoutCard(request, context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // ==================== 4. الترويسة العلوية الثابتة ====================
                Positioned(
                  top: 0, left: 0, right: 0, height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                    child: const SafeArea(
                      child: Center(
                        child: Text('الخزينة والمالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ==================== بناء كارت السحب المبسط ====================
  Widget _buildSimplifiedPayoutCard(Map<String, dynamic> request, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          // أيقونة المعلم
          const CircleAvatar(radius: 24, backgroundColor: Color(0xFFEDF7F7), child: Icon(Icons.person_rounded, color: Color(0xFF005F61), size: 24)),
          const SizedBox(width: 14),
          
          // تفاصيل الاسم والمبلغ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['teacher'] ?? 'اسم المعلم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${(request['amount'] ?? 0).toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))),
              ],
            ),
          ),
          
          // زر الموافقة
          ElevatedButton(
            onPressed: () {
              context.read<AdminCubit>().approveWithdrawalRequest(
                requestId: request['id'] ?? '', 
                teacherId: request['teacherId'] ?? '', 
                amount: (request['amount'] ?? 0).toDouble()
              );
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحويل المبلغ للمعلم بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF27AE60)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: Size.zero),
            child: const Text('تحويل', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== رسالة عدم وجود طلبات ====================
  Widget _buildEmptyStateWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.verified_user_rounded, color: const Color(0xFF2ECC71).withAlpha((0.2 * 255).toInt()), size: 80),
            const SizedBox(height: 16),
            const Text('ممتاز!\nلا توجد أي طلبات سحب معلقة حالياً.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.grey, height: 1.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}