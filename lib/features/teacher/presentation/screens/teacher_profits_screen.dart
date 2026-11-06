import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherFinancialScreen extends StatefulWidget {
  const TeacherFinancialScreen({super.key});

  @override
  State<TeacherFinancialScreen> createState() => _TeacherFinancialScreenState();
}

class _TeacherFinancialScreenState extends State<TeacherFinancialScreen> {
  void _openWithdrawalBottomSheet(double availableBalance) {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'vodafone';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(modalContext).viewInsets.bottom + 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('طلب سحب أرباح', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 6),
                Text('الرصيد المتاح للسحب: ${availableBalance.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 25),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(hintText: 'المبلغ المطلوب سحبه',  filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 20),
                const Text('طريقة الاستلام', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildWithdrawMethodTile('vodafone', 'محفظة فودافون كاش', Icons.phone_android_rounded, selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                const SizedBox(height: 10),
                _buildWithdrawMethodTile('bank', 'تحويل بنكي مباشر', Icons.account_balance_rounded, selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final double? amount = double.tryParse(amountController.text.trim());
                      if (amount != null && amount > 0 && amount <= availableBalance) {
                        
                        final String formalMethod = selectedMethod == 'vodafone' ? 'vodafone_cash' : 'bank_transfer';
                        
                        BlocProvider.of<TeacherCubit>(context).requestWithdrawal(amount, formalMethod);
                        Navigator.pop(modalContext); 
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب السحب للإدارة بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF005F61)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال مبلغ صحيح ولا يتجاوز الرصيد المتاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('تأكيد السحب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawMethodTile(String id, String title, IconData icon, String selectedValue, Function(String) onChanged) {
    bool isSelected = id == selectedValue;
    return GestureDetector(
      onTap: () => onChanged(id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFF8FAFC) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? const Color(0xFF005F61) : Colors.grey.shade200, width: isSelected ? 2 : 1)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF005F61) : Colors.grey),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: AppColors.textMain))),
            Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? const Color(0xFF005F61) : Colors.grey[400]!, width: 2)), child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF005F61), shape: BoxShape.circle))) : null),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.32;

    return BlocBuilder<TeacherCubit, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoaded) {
          final profile = state.teacherProfile;
          final double availableBalance = (profile['availableBalance'] ?? 0.0).toDouble();
          final double pendingBalance = (profile['pendingBalance'] ?? 0.0).toDouble();
          final transactions = state.transactions;

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
                          const Text('السجل المالي للاشتراكات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 16),
                          
                          if (transactions.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('لا توجد عمليات اشتراك مسجلة حالياً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)))),
                          
                          ...transactions.map((trans) {
                            String formattedDate = '';
                            if (trans['createdAt'] != null && trans['createdAt'] is Timestamp) {
                              final DateTime date = (trans['createdAt'] as Timestamp).toDate();
                              formattedDate = '${date.year}/${date.month}/${date.day}';
                            }

                            final double teacherNetProfit = (trans['teachersProfit'] ?? 0.0).toDouble();
                            final String transPackageName = trans['packageName'] ?? 'اشتراك باقة العلوم';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                              child: Row(
                                children: [
                                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEAFAF1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF27AE60), size: 20)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, 
                                      children: [
                                        Text(transPackageName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis), 
                                        const SizedBox(height: 2),
                                        Text(formattedDate, style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold))
                                      ]
                                    )
                                  ),
                                  Text('+ ${teacherNetProfit.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0, height: headerHeight,
                    child: Container(
                      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF005F61), Color(0xFF003D3F)]), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('الأرباح القابلة للسحب', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
                              const SizedBox(height: 4),
                              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${availableBalance.toStringAsFixed(0)} ', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)), const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('ج.م', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))))]),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Text('أرباح معلقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)), const SizedBox(height: 4), Text('${pendingBalance.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))]))),
                                  const SizedBox(width: 12),
                                  Expanded(child: SizedBox(height: 60, child: ElevatedButton.icon(onPressed: () => _openWithdrawalBottomSheet(availableBalance), icon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF005F61), size: 18), label: const Text('سحب الأرباح', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF005F61))), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0)))),
                                ],
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
        if (state is TeacherLoading || state is TeacherInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF005F61))));
        }
        if (state is TeacherError) {
          return Scaffold(body: Center(child: Text(state.message, style: const TextStyle(fontFamily: 'Cairo', color: Colors.redAccent, fontWeight: FontWeight.bold))));
        }
        return const SizedBox();
      },
    );
  }
}