import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ManageTextSummaryScreen extends StatefulWidget {
  final String lessonName;
  final List<dynamic>? initialSummaries; 

  const ManageTextSummaryScreen({
    super.key,
    required this.lessonName,
    this.initialSummaries,
  });

  @override
  State<ManageTextSummaryScreen> createState() => _ManageTextSummaryScreenState();
}

class _ManageTextSummaryScreenState extends State<ManageTextSummaryScreen> {
  late List<Map<String, dynamic>> _summaries;

  @override
  void initState() {
    super.initState();
    _summaries = [];
    if (widget.initialSummaries != null) {
      for (var element in widget.initialSummaries!) {
        if (element is Map) {
          _summaries.add(Map<String, dynamic>.from(element));
        } else {
          _summaries.add({
            'originalText': 'ملخص عام',
            'summaryText': element.toString(),
          });
        }
      }
    }
  }

  // دالة مساعدة لتصميم حقل الإدخال
  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'Cairo'),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFF005F61), width: 2),
    ),
  );

  void _openSummaryDialog({int? index}) {
    final TextEditingController originalController = TextEditingController(
      text: index != null ? (_summaries[index]['originalText'] ?? '') : ''
    );
    final TextEditingController summaryController = TextEditingController(
      text: index != null ? (_summaries[index]['summaryText'] ?? '') : ''
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(index == null ? 'إضافة ملخص جديد' : 'تعديل الملخص', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: originalController, decoration: _inputDecoration('العنوان / الجملة')),
            const SizedBox(height: 15),
            TextField(controller: summaryController, maxLines: 3, decoration: _inputDecoration('المحتوى المختصر')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              setState(() {
                if (index == null) {
                  _summaries.add({'originalText': originalController.text, 'summaryText': summaryController.text});
                } else {
                  _summaries[index] = {'originalText': originalController.text, 'summaryText': summaryController.text};
                }
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteSummary(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا الملخص؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () { setState(() => _summaries.removeAt(index)); Navigator.pop(context); }, child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF005F61),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF005F61),
        onPressed: () => _openSummaryDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: _summaries.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notes, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text('لا توجد ملخصات مضافة حالياً', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _summaries.length,
                    itemBuilder: (context, index) {
                      final item = _summaries[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          title: Text(item['originalText'] ?? 'بدون عنوان', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(item['summaryText'] ?? '', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[700])),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Color(0xFF005F61)), onPressed: () => _openSummaryDialog(index: index)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteSummary(index)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _summaries),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F61),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('حفظ التغييرات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}