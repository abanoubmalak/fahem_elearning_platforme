// lib/features/admin/presentation/screens/admin_financials_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminTreasuryScreen extends StatelessWidget {
  const AdminTreasuryScreen({super.key});

  // ── تأكيد الموافقة أو الرفض ──
  void _confirmAction(BuildContext context, {required bool isApprove, required Map<String, dynamic> request}) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isApprove ? 'تأكيد صرف المبلغ' : 'رفض طلب السحب',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Text(
            isApprove
                ? 'هل أنت متأكد من صرف مبلغ ${request['amount']} ج.م للمعلم "${request['teacherName']}"؟'
                : 'هل أنت متأكد من رفض طلب السحب الخاص بـ "${request['teacherName']}"؟ سيتم إرجاع المبلغ لرصيده المتاح.',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final cubit = context.read<AdminCubit>();
                final double amount = (request['amount'] ?? 0).toDouble();
                final String teacherId = request['teacherId'] ?? '';
                final String requestId = request['id'] ?? '';

                if (isApprove) {
                  await cubit.approveWithdrawalRequest(requestId: requestId, teacherId: teacherId, amount: amount);
                } else {
                  await cubit.rejectWithdrawalRequest(requestId: requestId, teacherId: teacherId, amount: amount);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isApprove ? 'تم صرف المبلغ بنجاح' : 'تم رفض الطلب وإرجاع المبلغ',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: isApprove ? const Color(0xFF27AE60) : Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(
                isApprove ? 'تأكيد الصرف' : 'تأكيد الرفض',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isApprove ? const Color(0xFF27AE60) : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMethod(String? method) {
    switch (method) {
      case 'vodafone_cash':
        return 'فودافون كاش';
      case 'bank_transfer':
        return 'تحويل بنكي';
      default:
        return method ?? 'غير محدد';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.year}/${date.month}/${date.day}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.18;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ── المحتوى ──
            Positioned.fill(
              child: BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoading || state is AdminInitial) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
                  }
                  if (state is AdminError) {
                    return Center(
                      child: Text(state.message, style: const TextStyle(fontFamily: 'Cairo', color: Colors.redAccent)),
                    );
                  }

                  final requests = state is AdminLoaded ? state.payoutRequests : <Map<String, dynamic>>[];

                  if (requests.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: headerHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد طلبات سحب معلّقة حالياً',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 40),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final double amount = (request['amount'] ?? 0).toDouble();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF6E5), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFE6A100), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request['teacherName'] ?? 'معلم غير معروف',
                                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_formatMethod(request['method'])} • ${_formatDate(request['createdAt'])}',
                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${amount.toStringAsFixed(0)} ج.م',
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005F61)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _confirmAction(context, isApprove: false, request: request),
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    label: const Text('رفض', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmAction(context, isApprove: true, request: request),
                                    icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                                    label: const Text('موافقة وصرف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF27AE60),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ── الهيدر الموحد ──
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        const Text('طلبات السحب المعلّقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
}