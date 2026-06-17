// lib/features/teacher/presentation/screens/tabs/teacher_subjects_tab.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_units_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_profile_screen.dart'; 
import 'package:flutter/material.dart';

class TeacherSubjectsTab extends StatefulWidget {
  const TeacherSubjectsTab({super.key});

  @override
  State<TeacherSubjectsTab> createState() => _TeacherSubjectsTabState();
}

class _TeacherSubjectsTabState extends State<TeacherSubjectsTab> {
  // 1. بيانات المدرس الثابتة (مادة تخصص واحدة ومراحل متعددة مخصصة من الأدمن)
  final String _teacherName = 'أ. أبانوب';
  final String _specialty = 'الرياضيات'; 
  
  final List<Map<String, dynamic>> _myAssignedCourses = [
    {'stage': 'الصف الأول الإعدادي', 'videos': 12, 'pdfs': 8, 'quizzes': 4},
    {'stage': 'الصف الثاني الإعدادي', 'videos': 15, 'pdfs': 10, 'quizzes': 5},
    {'stage': 'الصف الثالث الإعدادي', 'videos': 18, 'pdfs': 12, 'quizzes': 6},
  ];

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // 💎 التعديل الهندسي الأهم: وضع قائمة الدروس في الخلفية (أولاً في الكود) 💎
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _myAssignedCourses.length,
                padding: EdgeInsets.fromLTRB(0, headerHeight -20, 0, 40),
                itemBuilder: (context, index) {
                  final course = _myAssignedCourses[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.class_rounded, color: Color(0xFF005F61), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course['stage'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('منهج مادة $_specialty', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFF1F5F9), thickness: 1)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat(Icons.play_circle_outline_rounded, '${course['videos']} فيديو'),
                            _buildMiniStat(Icons.description_outlined, '${course['pdfs']} ملفات'),
                            _buildMiniStat(Icons.assignment_outlined, '${course['quizzes']} كويز', color: const Color(0xFFE6A100)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherUnitsScreen(
                                    stageName: course['stage'],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.folder_open_rounded, size: 16, color: Colors.white),
                            label: const Text('عرض الوحدات وإدارة المنهج', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005F61),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 💎 وضع الهيدر العلوي فوق القائمة (ثانياً في الكود) لحماية أزراره وجعلها قابلة للضغط 💎
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight-30,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                ),
                //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'أهلاً بحضرتك، $_teacherName',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          
                          // الزر الآن حي ومحمي في الطبقة العلوية
                          IconButton(
                            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => const TeacherProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'تخصصك المعتمد: $_specialty',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE6A100)),
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
    );
  }

  Widget _buildMiniStat(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color ?? Colors.grey[700], fontWeight: FontWeight.bold)),
      ],
    );
  }
}