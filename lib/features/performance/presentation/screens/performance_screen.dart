// lib/features/performance/presentation/screens/performance_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 استدعاء الأوث لمعرفة الطالب الحالي
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

enum SubjectType {
  science('العلوم', 'sci'),
  math('الرياضيات', 'math'),
  arabic('اللغة العربية', 'ara'),
  english('اللغة الإنجليزية', 'eng'),
  socialStudies('الدراسات الاجتماعية', 'soc'),
  unknown('مادة دراسية', 'unknown');

  final String arabicName;
  final String firebasePrefix;
  const SubjectType(this.arabicName, this.firebasePrefix);

  static String fromId(String docId) {
    final lowerId = docId.toLowerCase();
    for (var type in SubjectType.values) {
      if (type != SubjectType.unknown && lowerId.contains(type.firebasePrefix)) {
        return type.arabicName;
      }
    }
    return SubjectType.unknown.arabicName;
  }
}

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {

  double _calculateSubjectPerformance(double watch, double quiz) {
    return (watch * 0.4) + (quiz * 0.6);
  }

  @override
  Widget build(BuildContext context) {
    // 💎 تحديد هوية الطالب الحالي لنجلب بياناته هو فقط
    final String currentStudentId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // 💎 التعديل المنطقي: قراءة جدول تقدم الطالب بدلاً من جدول المنهج 💎
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('student_progress')
              .where('studentId', isEqualTo: currentStudentId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
            }
            // إذا لم يقم الطالب بأي نشاط بعد
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد بيانات أداء حالياً، ابدأ بمشاهدة الدروس وحل الاختبارات!', 
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)
                )
              );
            }

            double totalOverallScore = 0.0;
            Map<String, Map<String, dynamic>> aggregatedData = {};

            // 1. تجميع بيانات الطالب حسب المادة
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              String subjectId = data['subjectId'] ?? 'unknown';
              String subjectName = SubjectType.fromId(subjectId);

              if (!aggregatedData.containsKey(subjectName)) {
                aggregatedData[subjectName] = {'watchCount': 0.0, 'quizSum': 0.0, 'total': 0};
              }

              bool isWatched = data['isVideoWatched'] ?? false;
              double quiz = (data['quizScore'] ?? 0.0).toDouble();
              // توحيد النسبة لتكون من 0 إلى 1 (لأن الدرجة قد تكون من 10)
              if (quiz > 1.0) quiz = quiz / 10.0; 

              aggregatedData[subjectName]!['watchCount'] += isWatched ? 1.0 : 0.0;
              aggregatedData[subjectName]!['quizSum'] += quiz;
              aggregatedData[subjectName]!['total'] += 1;
            }

            // 2. حساب المتوسطات لكل مادة وتجهيزها للواجهة
            List<Map<String, dynamic>> dynamicSubjectList = [];
            aggregatedData.forEach((name, stats) {
              int count = stats['total'];
              double watchProgress = stats['watchCount'] / count;
              double quizScore = stats['quizSum'] / count;
              double subjectScore = _calculateSubjectPerformance(watchProgress, quizScore);

              totalOverallScore += subjectScore;
              dynamicSubjectList.add({
                'subject': name,
                'watchProgress': watchProgress,
                'quizScore': quizScore,
                'subjectScore': subjectScore,
              });
            });

            // 3. حساب النسبة الكلية للوحة العلوية
            double overallScore = dynamicSubjectList.isNotEmpty 
                ? (totalOverallScore / dynamicSubjectList.length) 
                : 0.0;

            // ================== التصميم بالأسفل ثابت 100% ==================
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('مؤشر الأداء الإجمالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110, height: 110,
                            child: CircularProgressIndicator(value: overallScore > 0 ? overallScore : 0.02, strokeWidth: 10, backgroundColor: Colors.white12, color: const Color(0xFFE6A100), strokeCap: StrokeCap.round),
                          ),
                          Text('${(overallScore * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(overallScore > 0.5 ? 'مستوى استيعابك العام ممتاز يا بطل! 🏆' : 'تابع المذاكرة بجد لتطوير أدائك! 🎯', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: dynamicSubjectList.length,
                    itemBuilder: (context, index) {
                      final item = dynamicSubjectList[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, color: Color(0xFF005F61), size: 22),
                                const SizedBox(width: 12),
                                Expanded(child: Text(item['subject'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain))),
                                Text('${(item['subjectScore'] * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: item['subjectScore'], backgroundColor: const Color(0xFFF1F5F9), color: const Color(0xFF005F61), minHeight: 6)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildSubStat(label: 'الفيديوهات', percent: (item['watchProgress'] * 100).toStringAsFixed(0), icon: Icons.play_circle_outline_rounded)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildSubStat(label: 'الاختبارات', percent: (item['quizScore'] * 100).toStringAsFixed(0), icon: Icons.assignment_outlined, color: const Color(0xFFE6A100))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubStat({required String label, required String percent, required IconData icon, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(child: Text('$label:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text('%$percent', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.grey[700])),
      ],
    );
  }
}