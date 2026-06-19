// lib/features/teacher/presentation/screens/manage_sections/manage_text_summary_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ManageTextSummaryScreen extends StatefulWidget {
  final String lessonName;
  final String? initialSummary; 

  const ManageTextSummaryScreen({
    super.key,
    required this.lessonName,
    this.initialSummary,
  });

  @override
  State<ManageTextSummaryScreen> createState() => _ManageTextSummaryScreenState();
}

class _ManageTextSummaryScreenState extends State<ManageTextSummaryScreen> {
  late TextEditingController _summaryController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.initialSummary ?? '');
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _saveSummary() {
    if (_formKey.currentState!.validate()) {
      final String newText = _summaryController.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ وتحديث الملخص النصي بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.primary));
      Navigator.pop(context, newText); 
    }
  }

  void _deleteSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [Icon(Icons.delete_forever_rounded, color: Colors.redAccent), SizedBox(width: 8), Text('حذف الملخص', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold))]),
            content: const Text('هل أنت متأكد من حذف هذا الملخص نهائياً؟ سيتم إخفاؤه من شاشات الطلاب.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold))),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الملخص النصي نهائياً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                  Navigator.pop(context, null); 
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('نعم، احذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;
    final bool hasExistingContent = widget.initialSummary != null && widget.initialSummary!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      resizeToAvoidBottomInset: true, 
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('محرر الشرح الأكاديمي المباشر:', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _summaryController,
                        maxLines: 10, 
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, height: 1.6, color: AppColors.textMain),
                        validator: (value) => value!.trim().isEmpty ? 'لا يمكن حفظ ملخص فارغ. اكتب نصاً أو قم باستخدام زر الحذف.' : null,
                        decoration: InputDecoration(hintText: 'اكتب هنا خلاصة القوانين أو الشرح المباشر للدرس...', hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey), filled: true, fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5))),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _saveSummary, icon: const Icon(Icons.save_rounded, color: Colors.white), label: Text(hasExistingContent ? 'حفظ التعديلات' : 'نشر الملخص الجديد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                      if (hasExistingContent) ...[
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _deleteSummary, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent), label: const Text('حذف الملخص نهائياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-20,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              // 💎💎 هذا هو التعديل الذي أنهى التجميد تماماً 💎💎
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [const Text('إدارة الملخص النصي', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)])),
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
}