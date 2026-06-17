// lib/features/teacher/presentation/screens/teacher_financial_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TeacherFinancialScreen extends StatefulWidget {
  const TeacherFinancialScreen({super.key});

  @override
  State<TeacherFinancialScreen> createState() => _TeacherFinancialScreenState();
}

class _TeacherFinancialScreenState extends State<TeacherFinancialScreen> {
  // ==================== 1. البيانات الوهمية (Mock Data) ====================
  double _availableBalance = 3450.0;
  double _pendingBalance = 0.0;
  final int _totalStudents = 145;

  final List<Map<String, dynamic>> _transactions = [
    {'student': 'أحمد أبانوب', 'subject': 'الكيمياء', 'amount': 21.0, 'date': 'اليوم، 10:30 ص'},
    {'student': 'مريم محمود', 'subject': 'الكيمياء', 'amount': 21.0, 'date': 'اليوم، 09:15 ص'},
    {'student': 'يوسف علي', 'subject': 'الأحياء', 'amount': 21.0, 'date': 'أمس، 08:00 م'},
    {'student': 'سارة إبراهيم', 'subject': 'الكيمياء', 'amount': 21.0, 'date': 'أمس، 05:45 م'},
    {'student': 'عمر خالد', 'subject': 'الأحياء', 'amount': 21.0, 'date': '15 يونيو، 02:00 م'},
  ];

  // ==================== 2. منطق سحب الأرباح (Withdrawal Logic) ====================
  void _openWithdrawalSheet() {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'fawry';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(context).viewInsets.bottom + 25),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('طلب سحب الأرباح', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(height: 8),
                  Text('الرصيد المتاح للسحب: $_availableBalance ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF005F61), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  // حقل إدخال المبلغ
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'المبلغ المراد سحبه',
                      labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      suffixText: 'ج.م',
                      suffixStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF005F61)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text('طريقة الاستلام:', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // خيارات طرق السحب
                  _buildWithdrawMethodTile('fawry', 'محفظة فودافون كاش / فوري', Icons.phone_android_rounded, selectedMethod, (val) => setSheetState(() => selectedMethod = val)),
                  const SizedBox(height: 10),
                  _buildWithdrawMethodTile('bank', 'تحويل بنكي مباشر', Icons.account_balance_rounded, selectedMethod, (val) => setSheetState(() => selectedMethod = val)),

                  const SizedBox(height: 35),
                  
                  // زر التأكيد
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        double requestedAmount = double.tryParse(amountController.text) ?? 0.0;
                        if (requestedAmount <= 0 || requestedAmount > _availableBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المبلغ غير صحيح أو يتجاوز الرصيد المتاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                          return;
                        }

                        // خصم المبلغ من المتاح وإضافته للمعلق
                        setState(() {
                          _availableBalance -= requestedAmount;
                          _pendingBalance += requestedAmount;
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل طلب السحب بنجاح وهو الآن قيد المراجعة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF2ECC71)));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('تأكيد وإرسال الطلب للمنصة', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF005F61),
          elevation: 0,
          title: const Text('لوحة الأرباح المالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          //leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== 3. كارت الرصيد الرئيسي ====================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF005F61), Color(0xFF003D3F)]),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                ),
                child: Column(
                  children: [
                    const Text('الرصيد المتاح للسحب', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${_availableBalance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFFE6A100))),
                    const SizedBox(height: 20),
                    
                    // حالة الطلبات المعلقة إن وجدت
                    if (_pendingBalance > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text('رصيد قيد المراجعة: ${_pendingBalance.toStringAsFixed(2)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================== 4. الإحصائيات والرسم البياني ====================
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('إجمالي الطلاب', '$_totalStudents', Icons.groups_rounded, const Color(0xFF005F61))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildStatCard('أرباح الشهر', '1850', Icons.trending_up_rounded, const Color(0xFF2ECC71))),
                      ],
                    ),
                    const SizedBox(height: 25),

                    

                    // ==================== 5. سجل العمليات (Ledger) ====================
                    const Text('سجل العمليات المالية (الحديثة)', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    const SizedBox(height: 15),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return _buildTransactionTile(tx);
                      },
                    ),
                    const SizedBox(height: 100), // مساحة لزر السحب
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // زر طلب السحب العائم والثابت
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 15, 20, MediaQuery.of(context).padding.bottom + 15),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))]),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _availableBalance > 0 ? _openWithdrawalSheet : null,
              icon: const Icon(Icons.payments_rounded, color: Colors.white),
              label: const Text('تقديم طلب سحب أرباح', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== الويدجتس المساعدة ====================

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.commonShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        ],
      ),
    );
  }

  // كارت سجل العمليات (Ledger)
  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEAFAF1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF2ECC71), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اشتراك: ${tx['student']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 2),
                Text('مادة ${tx['subject']} • ${tx['date']}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Text('+${tx['amount']} ج.م', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
        ],
      ),
    );
  }

  // رسم بياني محلي (Native) خفيف واحترافي
  Widget _buildNativeBarChart() {
    final List<double> heights = [40, 60, 45, 80, 50, 100]; // نسب وهمية لارتفاع العواميد
    final List<String> months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.commonShadow),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (index) {
          bool isCurrentMonth = index == 5; // تمييز الشهر الحالي
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 20,
                height: heights[index],
                decoration: BoxDecoration(
                  color: isCurrentMonth ? const Color(0xFFE6A100) : const Color(0xFF005F61).withAlpha(100),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 10),
              Text(months[index], style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal, color: isCurrentMonth ? AppColors.textMain : Colors.grey)),
            ],
          );
        }),
      ),
    );
  }

  // خيار اختيار طريقة الدفع/الاستلام
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
}