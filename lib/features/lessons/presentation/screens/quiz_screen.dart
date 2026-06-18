// lib/features/lessons/screens/quiz_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String lessonTitle;
  final List<dynamic> questions; 
  final String subjectId; // 👈 استقبال المعرفات
  final String studentTerm;

  const QuizScreen({
    super.key,
    required this.lessonTitle,
    required this.questions, 
    required this.subjectId,
    required this.studentTerm,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;

  void _updateLessonProgressInFirebase({
    required int studentScore, 
    required int totalQuestions, 
    required String currentLessonTitle,
  }) async {
    try {
      // 👈 تم تعديل المسار ليكون ديناميكي بناءً على المادة والترم لضمان الحفظ المظبوط
      final documentRef = FirebaseFirestore.instance.collection('subjects_content').doc('${widget.studentTerm}_${widget.subjectId}');
      
      final docSnapshot = await documentRef.get();
      if (!docSnapshot.exists) return;

      final data = docSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> units = data['units'] ?? [];

      bool updated = false;

      double calculatedQuizScore = totalQuestions > 0 ? (studentScore / totalQuestions) : 0.0;

      for (var unit in units) {
        final List<dynamic> lessons = unit['lessons'] ?? [];
        for (var lesson in lessons) {
          if (lesson['title'] == currentLessonTitle) {
            lesson['isCompleted'] = true; 
            lesson['quizScore'] = calculatedQuizScore; // 👈 ستقوم بإعادة كتابة النتيجة (Overwriting) في كل محاولة
            updated = true;
            break;
          }
        }
        if (updated) break;
      }

      if (updated) {
        await documentRef.update({'units': units});
        debugPrint('🎯 تم بنجاح حفظ حالة المشاهدة ودرجة الاختبار ($calculatedQuizScore) في Firestore!');
      }
    } catch (e) {
      debugPrint('❌ فشل تحديث السيرفر: $e');
    }
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex == null) return;

    if (_selectedAnswerIndex == widget.questions[_currentQuestionIndex]['correctIndex']) {
      _score++;
    }

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null; 
      });
    } else {
      _updateLessonProgressInFirebase(
        studentScore: _score,
        totalQuestions: widget.questions.length,
        currentLessonTitle: widget.lessonTitle,
      );
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Center(child: Text('🎉 أحسنت يا بطل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('لقد أتممت اختبار الدرس بنجاح، نتيجتك هي:', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMain)),
              const SizedBox(height: 15),
              Text('$_score من ${widget.questions.length}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))),
              const SizedBox(height: 12),
              const Text('🏆 ممتاز! تم تسجيل مشاهدة الدرس وحفظ درجتك تلقائياً في لوحة أدائك الحية.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                child: const Text('العودة للدرس', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lessonTitle, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textMain)), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: AppColors.textMain)),
        body: const Center(child: Text('لا توجد أسئلة متاحة لهذا الدرس حالياً.', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold))),
      );
    }

    final currentQuestion = widget.questions[_currentQuestionIndex];
    final double progress = (_currentQuestionIndex + 1) / widget.questions.length;
    final String cleanQuestionText = (currentQuestion['question'] ?? 'سؤال غير متوفر').toString().replaceAll('"', '').replaceAll('(', '').replaceAll(')', '');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 18), onPressed: () => Navigator.pop(context)),
        title: Text(widget.lessonTitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              color: Colors.white, padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('السؤال ${_currentQuestionIndex + 1} من ${widget.questions.length}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Row(children: [Icon(Icons.timer_outlined, color: Colors.redAccent, size: 16), SizedBox(width: 4), Text('15:00', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent))]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[100], color: AppColors.primary, minHeight: 6, borderRadius: BorderRadius.circular(3)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.commonShadow),
                      child: Text(cleanQuestionText, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005F61), height: 1.6)),
                    ),
                    const SizedBox(height: 25),
                    ...List.generate((currentQuestion['options'] as List<dynamic>?)?.length ?? 0, (index) => _buildOptionCard(index: index, text: currentQuestion['options'][index])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 15),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _selectedAnswerIndex != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), disabledBackgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                  child: Text(_currentQuestionIndex == widget.questions.length - 1 ? 'عرض النتيجة وتأكيد الفهم' : 'السؤال التالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: _selectedAnswerIndex != null ? Colors.white : Colors.grey[600])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required int index, required String text}) {
    final bool isSelected = _selectedAnswerIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAnswerIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFEDF7F7) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[200]!, width: isSelected ? 2 : 1), boxShadow: isSelected ? null : AppColors.commonShadow),
        child: Row(
          children: [
            CircleAvatar(radius: 12, backgroundColor: isSelected ? AppColors.primary : Colors.grey[100], child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : Text(String.fromCharCode(65 + index), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold))),
            const SizedBox(width: 15),
            Expanded(child: Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : AppColors.textMain))),
          ],
        ),
      ),
    );
  }
}