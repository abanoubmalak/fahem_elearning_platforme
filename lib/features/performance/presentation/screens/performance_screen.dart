// lib/features/performance/presentation/screens/performance_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  // 1. بيانات الأداء المخزنة لكل مادة
  final List<Map<String, dynamic>> _subjectPerformanceData = [
    {'subject': 'اللغة العربية', 'watchProgress': 0.80, 'quizScore': 0.70},
    {'subject': 'اللغة الإنجليزية', 'watchProgress': 0.50, 'quizScore': 0.40},
    {'subject': 'الرياضيات', 'watchProgress': 0.90, 'quizScore': 0.85},
    {'subject': 'العلوم', 'watchProgress': 1.00, 'quizScore': 0.95},
    {'subject': 'الدراسات الاجتماعية', 'watchProgress': 0.40, 'quizScore': 0.60},
  ];

  // 2. دالة حساب أداء المادة الواحدة بناءً على الأوزان النسبية (40% مشاهدة، 60% اختبار)
  double _calculateSubjectPerformance(double watch, double quiz) {
    return (watch * 0.4) + (quiz * 0.6);
  }

  // 3. دالة حساب الأداء الإجمالي العام لكافة المواد بالتطبيق
  double _calculateOverallPerformance() {
    double total = 0.0;
    for (var data in _subjectPerformanceData) {
      total += _calculateSubjectPerformance(data['watchProgress'], data['quizScore']);
    }
    return total / _subjectPerformanceData.length;
  }

  @override
  Widget build(BuildContext context) {
    final double overallScore = _calculateOverallPerformance();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Column(
          children: [
            // ==================== 1. الترويسة العلوية الضخمة (مؤشر الأداء العام) ====================
            Container(
              width: double.infinity,
              // أضفنا مسافة علوية تساوي الـ Status Bar عشان العناصر متخبطش في الكاميرا
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'مؤشر الأداء الإجمالي',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  
                  // الدائرة الضخمة الجذابة لعرض النسبة الكلية
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: overallScore,
                          strokeWidth: 10,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFFE6A100), // اللون الذهبي
                          strokeCap: StrokeCap.round, // بيخلي حواف شريط التقدم دائرية وشيك
                        ),
                      ),
                      Text(
                        '${(overallScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'مستوى استيعابك العام ممتاز يا بطل! 🏆',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white.withAlpha((0.8 * 255).toInt())),
                  ),
                ],
              ),
            ),

            // ==================== 2. تفاصيل أداء كل مادة على حدة ====================
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // مسافة سفلية لحماية الكروت من شريط التنقل
                itemCount: _subjectPerformanceData.length,
                itemBuilder: (context, index) {
                  final data = _subjectPerformanceData[index];
                  final double subjectScore = _calculateSubjectPerformance(data['watchProgress'], data['quizScore']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صف رأس كارت المادة
                        Row(
                          children: [
                            Icon(data['icon'] ?? Icons.menu_book_rounded, color: const Color(0xFF005F61), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['subject'],
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                              ),
                            ),
                            // نسبة أداء المادة المحسوبة
                            Text(
                              '${(subjectScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005F61)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // شريط التقدم الخطي
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: subjectScore,
                            backgroundColor: const Color(0xFFF1F5F9),
                            color: const Color(0xFF005F61),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // المقارنة الفرعية التفصيلية محمية بـ Expanded لضمان عدم حدوث تداخل
                        Row(
                          children: [
                            Expanded(
                              child: _buildSubStat(
                                label: 'الفيديوهات',
                                percent: (data['watchProgress'] * 100).toStringAsFixed(0),
                                icon: Icons.play_circle_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSubStat(
                                label: 'الاختبارات',
                                percent: (data['quizScore'] * 100).toStringAsFixed(0),
                                icon: Icons.assignment_outlined,
                                color: const Color(0xFFE6A100),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // باني الإحصائيات الفرعية تم تصحيحه ليتناسب مع الـ Expanded الخارجي
  Widget _buildSubStat({required String label, required String percent, required IconData icon, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '%$percent',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.grey[700]),
        ),
      ],
    );
  }
}