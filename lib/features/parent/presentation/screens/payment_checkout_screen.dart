// lib/features/parent/presentation/screens/payment_checkout_screen.dart
import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final double packageAmount; // 👈 السعر الموحد لكل مادة
  final Function(int) onTabSwitch;

  const PaymentCheckoutScreen({
    super.key,
    this.packageAmount = 150.0,
    required this.onTabSwitch,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  String? _selectedChildId;
  bool _isProcessing = false;

  Future<void> _processPayment(Map<String, dynamic> child, Map<String, dynamic> subject) async {
    if (_isProcessing) return;

    final String? teacherId = subject['teacherId'];
    if (teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذه المادة غير متاحة للدفع حالياً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final parentCubit = context.read<ParentCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => _PaymentProcessingDialog(
        onCompleted: () async {
          if (Navigator.canPop(dialogContext)) Navigator.of(dialogContext).pop();

          final error = await parentCubit.paySubscription(
            childId: child['id'],
            subjectId: subject['subjectId'],
            teacherId: teacherId,
            amount: widget.packageAmount,
          );

          if (mounted) {
            setState(() => _isProcessing = false);
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentCubit, ParentState>(
      builder: (context, state) {
        final pendingChildren = state.children.where((child) {
          final subjects = (child['subjects'] as List?) ?? [];
          return subjects.any((s) => s['isAvailable'] == true && s['isUnlocked'] == false);
        }).toList();

        if (pendingChildren.isNotEmpty) {
          if (_selectedChildId == null || !pendingChildren.any((c) => c['id'] == _selectedChildId)) {
            _selectedChildId = pendingChildren.first['id'];
          }
        } else {
          _selectedChildId = null;
        }

        final Map<String, dynamic> selectedChild = pendingChildren.firstWhere(
          (c) => c['id'] == _selectedChildId,
          orElse: () => <String, dynamic>{},
        );

        final List<Map<String, dynamic>> subjects = selectedChild.isEmpty
            ? []
            : List<Map<String, dynamic>>.from(selectedChild['subjects'] ?? []);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(),
            body: pendingChildren.isEmpty
                ? _buildAllPaidState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
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
                              items: pendingChildren.map((child) {
                                return DropdownMenuItem<String>(
                                  value: child['id'],
                                  child: Text(child['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildSectionTitle('المواد الدراسية (${selectedChild['stage'] ?? ''})'),
                        const SizedBox(height: 4),
                        Text(
                          'سعر اشتراك المادة الواحدة: ${widget.packageAmount.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        ...subjects.map((subject) => _buildSubjectCard(selectedChild, subject)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> child, Map<String, dynamic> subject) {
    final bool isUnlocked = subject['isUnlocked'] == true;
    final bool isAvailable = subject['isAvailable'] == true;
    final String name = subject['subjectName'] ?? '';

    Color badgeColor;
    String badgeText;
    if (isUnlocked) {
      badgeColor = const Color(0xFF27AE60);
      badgeText = 'مدفوعة';
    } else if (isAvailable) {
      badgeColor = const Color(0xFFE6A100);
      badgeText = '${widget.packageAmount.toStringAsFixed(0)} ج.م';
    } else {
      badgeColor = Colors.grey;
      badgeText = 'قريباً';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFFEAFAF1) : (isAvailable ? const Color(0xFFFEF6E5) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUnlocked ? Icons.check_circle_rounded : (isAvailable ? Icons.menu_book_rounded : Icons.lock_outline_rounded),
              color: isUnlocked ? const Color(0xFF27AE60) : (isAvailable ? const Color(0xFFE6A100) : Colors.grey),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14.5)),
          ),
          if (isAvailable && !isUnlocked)
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _processPayment(child, subject),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F61),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text('ادفع $badgeText', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: badgeColor.withAlpha(30), borderRadius: BorderRadius.circular(10)),
              child: Text(badgeText, style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, fontWeight: FontWeight.bold, color: badgeColor)),
            ),
        ],
      ),
    );
  }

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
          const Text('جميع المواد المتاحة لأبنائك مسددة بانتظام.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5, color: Colors.grey)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], end: Alignment.bottomLeft),
        ),
      ),
      title: const Text('إتمام عملية الدفع الرقمي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF1F2937))),
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
            Text(_isSuccess ? 'تم تسجيل العملية بنجاح' : 'يرجى الانتظار، لا تغلق الشاشة', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}