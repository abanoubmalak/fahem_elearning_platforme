// lib/features/lessons/screens/quiz_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String lessonTitle;

  const QuizScreen({
    super.key,
    required this.lessonTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;

  // هيكل البيانات المخزن للأسئلة المستوحاة من المتن العلمي مباشرة [cite: 2026-05-25]
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'يتكون الجدول الدوري الحديث من كم مجموعة رأسية؟',
      'options': ['10 مجموعات', '18 مجموعة', '7 مجموعات', '8 مجموعات'],
      'correctIndex': 1,
    },
    {
      'question': 'عناصر المجموعات (1A, 2A) تنتمي إلى أي فئة في الجدول الدوري؟',
      'options': ['الفئة P', 'الفئة D', 'الفئة S', 'الفئة F'],
      'correctIndex': 2,
    },
    {
      'question': 'لماذا تتميز الغازات الخاملة باستقرارها الكيميائي العالي في الظروف العادية؟',
      'options': [
        'لاكتمال مستوياتها الخارجية بالإلكترونات',
        'لأنها مواد فلزية قوية',
        'لقدرتها العالية على فقد الإلكترونات',
        'لأنها تقع في الفئة S'
      ],
      'correctIndex': 0,
    }
  ];

  void _nextQuestion() {
    if (_selectedAnswerIndex == null) return;

    // حساب الدرجة إذا كانت الإجابة صحيحة
    if (_selectedAnswerIndex == _questions[_currentQuestionIndex]['correctIndex']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null; // إعادة تعيين الاختيار للسؤال الجديد
      });
    } else {
      // إذا انتهت الأسئلة يتم عرض النتيجة التوضيحية الفورية
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
          title: const Center(
            child: Text(
              '🎉 أحسنت يا بطل',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'لقد أتممت اختبار الدرس بنجاح، نتيجتك هي:',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Cairo', color: AppColors.textMain),
              ),
              const SizedBox(height: 15),
              Text(
                '$_score من ${_questions.length}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6A100), // الذهبي الموحد للاختبارات
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق الديالوج
                  Navigator.pop(context); // العودة لشاشة الدرس
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text(
                  'العودة للدرس',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ==================== 1. مؤشر التقدم العلوي الذكي ====================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السؤال ${_currentQuestionIndex + 1} من ${_questions.length}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.redAccent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '15:00',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[100],
                    color: AppColors.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),

            // ==================== 2. جسم الاختبار الممتد ====================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // كارت عرض نص السؤال صراحة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.commonShadow,
                      ),
                      child: Text(
                        currentQuestion['question'],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F61), // اللون الفيروزي المميز للأسئلة
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // عرض الاختيارات الأربعة بشكل ديناميكي تفاعلي
                    ...List.generate(
                      currentQuestion['options'].length,
                      (index) => _buildOptionCard(
                        index: index,
                        text: currentQuestion['options'][index],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================== 3. زر الانتقال/التأكيد السفلي الموحد ====================
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 15),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedAnswerIndex != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A100), // اللون الذهبي المعتمد للاختبارات
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1 ? 'عرض النتيجة وتأكيد الفهم' : 'السؤال التالي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedAnswerIndex != null ? Colors.white : Colors.grey[600],
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

  // ويدجت بناء كارت الخيار التفاعلي
  Widget _buildOptionCard({required int index, required String text}) {
    final bool isSelected = _selectedAnswerIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswerIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDF7F7) : Colors.white, // تفتيح الخلفية عند الاختيار لإراحة العين
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? null : AppColors.commonShadow,
        ),
        child: Row(
          children: [
            // مؤشر دائري جذاب يعاكي تطبيقات القياس العالمية
            CircleAvatar(
              radius: 12,
              backgroundColor: isSelected ? AppColors.primary : Colors.grey[100],
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : Text(
                      String.fromCharCode(65 + index), // تحويل الأرقام إلى رموز صامتة A, B, C, D
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(width: 15),
            
            // نص الإجابة
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}