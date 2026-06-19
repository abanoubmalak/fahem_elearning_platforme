// lib/features/parent/presentation/screens/payment_checkout_screen.dart
import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final double packageAmount;
  final Function(int) onTabSwitch; // للانتقال السلس

  const PaymentCheckoutScreen({
    super.key,
    this.packageAmount = 150.0,
    required this.onTabSwitch,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  String _selectedPaymentMethod = 'card';
  String? _selectedChildId;
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    if (_selectedChildId == null) return;

    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentProcessingDialog(
        onCompleted: () {
          if (mounted) Navigator.of(context).pop(); 
          // 1. تحديث حالة الدفع في الـ Cubit
          context.read<ParentCubit>().paySubscription(_selectedChildId!);
          setState(() {
            _isProcessing = false;
            _selectedChildId = null; // إعادة تعيين الاختيار
          });
          // 2. توجيه ولي الأمر للشاشة الرئيسية فوراً
          widget.onTabSwitch(0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentCubit, ParentState>(
      builder: (context, state) {
        // فلترة الأبناء: إحضار من لم يدفع فقط
        final unpaidChildren = state.children.where((child) => child['isPaid'] == false).toList();

        // التحديد التلقائي لأول ابن غير مسدد
        if (unpaidChildren.isNotEmpty && _selectedChildId == null) {
          _selectedChildId = unpaidChildren.first['id'];
        } else if (unpaidChildren.isEmpty) {
          _selectedChildId = null;
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(),
            body: unpaidChildren.isEmpty
                ? _buildAllPaidState() // 👈 واجهة "لا توجد مستحقات"
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('اختر الابن المراد دفع مصاريفه'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedChildId,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF005F61)),
                                    onChanged: (val) => setState(() => _selectedChildId = val),
                                    items: unpaidChildren.map((child) {
                                      return DropdownMenuItem<String>(
                                        value: child['id'],
                                        child: Text(child['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              _buildSectionTitle('تفاصيل المستحقات'),
                              _buildInvoiceDetails(unpaidChildren.firstWhere((c) => c['id'] == _selectedChildId, orElse: () => {})['name'] ?? ''),
                              const SizedBox(height: 25),
                              _buildSectionTitle('اختر طريقة الدفع'),
                              _buildPaymentMethodTile(id: 'card', title: 'الدفع ببطاقة ائتمانية', icon: Icons.credit_card_rounded),
                              const SizedBox(height: 12),
                              _buildPaymentMethodTile(id: 'fawry', title: 'الدفع عبر فوري', icon: Icons.storefront_rounded),
                            ],
                          ),
                        ),
                      ),
                      _buildBottomBar(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // واجهة "تم السداد بالكامل"
  Widget _buildAllPaidState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFFEAFAF1), shape: BoxShape.circle),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF2ECC71), size: 70),
          ),
          const SizedBox(height: 20),
          const Text('لا توجد مستحقات مالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          const Text('جميع أبنائك المربوطين بالحساب مسددون للاشتراك.', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], end: Alignment.bottomLeft),
        ),
      ),
      title: const Text('إتمام عملية الدفع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
    );
  }

  Widget _buildInvoiceDetails(String childName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 15)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('اسم الطالب:', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey.shade600)),
              Text(childName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('القيمة:', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey.shade600)),
              Text('${widget.packageAmount.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({required String id, required String title, required IconData icon}) {
    final bool isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005F61).withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF005F61) : Colors.grey.shade200, width: isSelected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: isSelected ? const Color(0xFF005F61) : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade500, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14.5))),
            Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, color: isSelected ? const Color(0xFF005F61) : Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 18, offset: const Offset(0, -4))]),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الإجمالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.grey)),
                  Text('${widget.packageAmount.toStringAsFixed(0)} ج.م', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF005F61))),
                ],
              ),
            ),
            SizedBox(
              width: 180, height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: _isProcessing
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('ادفع الآن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentProcessingDialog extends StatefulWidget {
  final VoidCallback onCompleted;
  const _PaymentProcessingDialog({required this.onCompleted});
  @override
  State<_PaymentProcessingDialog> createState() => _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<_PaymentProcessingDialog> {
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSuccess = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _isSuccess
                  ? Container(key: const ValueKey('success'), width: 70, height: 70, decoration: const BoxDecoration(color: Color(0xFF1FAE6B), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 38))
                  : const SizedBox(key: ValueKey('loading'), width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF005F61))),
            ),
            const SizedBox(height: 22),
            Text(_isSuccess ? 'تمت عملية الدفع بنجاح' : 'جاري تنفيذ عملية الدفع...', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
            const SizedBox(height: 6),
            Text(_isSuccess ? 'تم تسجيل العملية بنجاح' : 'يرجى الانتظار، لا تغلق الشاشة', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}