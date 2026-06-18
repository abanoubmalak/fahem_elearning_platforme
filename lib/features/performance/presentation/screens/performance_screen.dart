// lib/features/performance/presentation/screens/performance_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('subjects_content').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('لا توجد بيانات أداء حالياً.', style: TextStyle(fontFamily: 'Cairo')));
            }

            double totalOverallScore = 0.0;
            List<Map<String, dynamic>> dynamicSubjectList = [];
            Set<String> addedSubjects = {}; 

            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> units = data['units'] ?? [];
              
              String subjectName = data['subjectName'] ?? data['title'] ?? SubjectType.fromId(doc.id);

              if (addedSubjects.contains(subjectName)) continue;

              int totalLessons = 0;
              int completedLessons = 0;
              double totalQuizScores = 0.0;

              for (var unit in units) {
                final List<dynamic> lessons = unit['lessons'] ?? [];
                totalLessons += lessons.length;
                for (var lesson in lessons) {
                  if (lesson['isCompleted'] == true) {
                    completedLessons++;
                  }
                  totalQuizScores += (lesson['quizScore'] ?? 0.0) as double;
                }
              }

              double watchProgress = totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;
              double quizScore = totalLessons > 0 ? (totalQuizScores / totalLessons) : 0.0; 

              double subjectScore = _calculateSubjectPerformance(watchProgress, quizScore);
              totalOverallScore += subjectScore;

              addedSubjects.add(subjectName);

              dynamicSubjectList.add({
                'subject': subjectName,
                'watchProgress': watchProgress,
                'quizScore': quizScore,
                'subjectScore': subjectScore,
              });
            }

            double overallScore = dynamicSubjectList.isNotEmpty 
                ? (totalOverallScore / dynamicSubjectList.length) 
                : 0.0;

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
                            child: CircularProgressIndicator(value: overallScore, strokeWidth: 10, backgroundColor: Colors.white12, color: const Color(0xFFE6A100), strokeCap: StrokeCap.round),
                          ),
                          Text('${(overallScore * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(overallScore > 0.5 ? 'مستوى استيعابك العام ممتاز يا بطل! 🏆' : 'تابع المذاكرة بجد لتطوير أدائك! 🎯', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
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