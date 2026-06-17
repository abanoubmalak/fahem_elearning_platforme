// lib/features/teacher/presentation/screens/manage_sections/teacher_quiz_editor_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TeacherQuizEditorScreen extends StatefulWidget {
  final String lessonName;
  const TeacherQuizEditorScreen({super.key, required this.lessonName});

  @override
  State<TeacherQuizEditorScreen> createState() => _TeacherQuizEditorScreenState();
}

class _TeacherQuizEditorScreenState extends State<TeacherQuizEditorScreen> {
  // قائمة الأسئلة (محاكاة للبيانات القادمة من السيرفر)
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'إذا كانت د(س) = س + ٥، فإن د(٢) تساوي:',
      'options': ['٣', '٥', '٧', '٩'],
      'correctIndex': 2,
    },
    {
      'question': 'مجموعة حل المعادلة س² - ٤ = ٠ في ح هي:',
      'options': ['{٢}', '{-٢}', '{٢، -٢}', 'Ø'],
      'correctIndex': 2,
    },
  ];

  // 💥 دالة ذكية مدمجة لـ إضافة وتعديل السؤال بتصميم تفاعلي 💥
  void _openQuestionEditorBottomSheet({int? editIndex}) {
    final bool isEditing = editIndex != null;
    
    final TextEditingController questionController = TextEditingController(
      text: isEditing ? _questions[editIndex]['question'] : '',
    );
    final List<TextEditingController> optionControllers = List.generate(
      4,
      (i) => TextEditingController(text: isEditing ? _questions[editIndex]['options'][i] : ''),
    );
    int selectedCorrectIndex = isEditing ? _questions[editIndex]['correctIndex'] : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(context).viewInsets.bottom + 30),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'تعديل بيانات السؤال' : 'إضافة سؤال اختبار جديد',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: questionController,
                    maxLines: 2,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'نص السؤال الأكاديمي',
                      labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('الأجوبة الأربعة (حدد زر الراديو بجانب الإجابة الصحيحة):', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...List.generate(4, (index) {
                    final bool isCorrect = selectedCorrectIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCorrect ? const Color(0xFFEAFAF1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isCorrect ? const Color(0xFF2ECC71) : Colors.transparent, width: 1),
                      ),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedCorrectIndex,
                            activeColor: const Color(0xFF2ECC71),
                            onChanged: (val) => setModalState(() => selectedCorrectIndex = val!),
                          ),
                          Expanded(
                            child: TextField(
                              controller: optionControllers[index],
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'الاختيار رقم (${index + 1})',
                                labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                                suffixText: isCorrect ? '(الإجابة النموذجية)' : null,
                                suffixStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Color(0xFF27AE60), fontWeight: FontWeight.bold),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isCorrect ? Colors.transparent : Colors.grey[200]!)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (questionController.text.trim().isEmpty || optionControllers.any((c) => c.text.trim().isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('برجاء إكمال السؤال وجميع الاختيارات الأربعة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                          );
                          return;
                        }

                        setState(() {
                          final newQuestionData = {
                            'question': questionController.text.trim(),
                            'options': optionControllers.map((c) => c.text.trim()).toList(),
                            'correctIndex': selectedCorrectIndex,
                          };

                          if (isEditing) {
                            _questions[editIndex] = newQuestionData;
                          } else {
                            _questions.add(newQuestionData);
                          }
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEditing ? 'تم تحديث السؤال بنجاح' : 'تم إضافة السؤال بنجاح', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.primary),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                      child: Text(isEditing ? 'حفظ التعديلات' : 'إدراج السؤال الجديد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف السؤال', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          content: const Text('هل أنت متأكد من حذف هذا السؤال من الاختبار؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {
                setState(() => _questions.removeAt(index));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف السؤال', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
              child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💎 توحيد الحسبة المحدثة للارتفاع هندسياً لمنع فجوات الـ Scroll 💎
    final double headerHeight = (MediaQuery.of(context).size.height * 0.20) - 20;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQuestionEditorBottomSheet(),
        backgroundColor: const Color(0xFFE6A100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('سؤال جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. قائمة عرض وإدارة الأسئلة (في الخلفية أولاً) ====================
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _questions.isEmpty
                    ? const Center(child: Text('الاختبار فارغ. ابدأ بإضافة سؤالك الأول.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _questions.length,
                        // 💎 ربط الـ Padding بالارتفاع الموحد الفعلي بانتظام 💎
                        padding: EdgeInsets.fromLTRB(0, headerHeight + 15, 0, 90),
                        itemBuilder: (context, qIndex) {
                          final qData = _questions[qIndex];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFFEDF7F7),
                                      child: Text('${qIndex + 1}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        qData['question'], 
                                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textMain),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                Column(
                                  children: List.generate(4, (oIndex) {
                                    final bool isCorrect = qData['correctIndex'] == oIndex;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isCorrect ? const Color(0xFFEAFAF1) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isCorrect ? const Color(0xFF2ECC71).withAlpha((0.3 * 255).toInt()) : Colors.grey[100]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(isCorrect ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, size: 14, color: isCorrect ? const Color(0xFF2ECC71) : Colors.grey),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              qData['options'][oIndex], 
                                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal, color: isCorrect ? const Color(0xFF27AE60) : AppColors.textMain),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                
                                const Divider(color: Color(0xFFF1F5F9), height: 24),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _openQuestionEditorBottomSheet(editIndex: qIndex),
                                      icon: const Icon(Icons.edit_rounded, size: 16),
                                      label: const Text('تعديل السؤال', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFE6A100)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _deleteQuestion(qIndex),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                      label: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),

            // ==================== 2. البانر الفيروزي العلوي (في المقدمة آخراً) ====================
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          // 💎 العودة الآمنة والمعمارية الصحيحة للحفاظ على الـ State والـ Memory 💎
                          onPressed: () => Navigator.pop(context), 
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('معدل أسئلة الاختبار', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
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