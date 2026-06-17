// lib/features/teacher/presentation/screens/dashboard/teacher_questions_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

class TeacherQuestionsScreen extends StatefulWidget {
  const TeacherQuestionsScreen({super.key});

  @override
  State<TeacherQuestionsScreen> createState() => _TeacherQuestionsScreenState();
}

class _TeacherQuestionsScreenState extends State<TeacherQuestionsScreen> {
  // محاكاة لأسئلة الطلاب
  final List<Map<String, dynamic>> _questions = [
    {'student': 'محمد أحمد', 'question': 'ممكن شرح تاني لمسألة التعبير الرمزي؟', 'isReplied': true},
    {'student': 'سارة علي', 'question': 'هو المثال التاني في صفحة 15 جاي في الامتحان؟', 'isReplied': false},
    {'student': 'يوسف خالد', 'question': 'شكراً جداً يا مستر، الشرح كان ممتاز!', 'isReplied': true},
  ];

  // دالة فتح صندوق الرد
  void _openReplyBottomSheet(int index) {
    final TextEditingController replyController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رد على: ${_questions[index]['student']}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: replyController,
                maxLines: 3,
                decoration: InputDecoration(hintText: 'اكتب ردك هنا...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  setState(() => _questions[index]['isReplied'] = true);
                  Navigator.pop(context);
                },
                child: const Text('إرسال الرد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = (MediaQuery.of(context).size.height * 0.20) - 20;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: const Color(0xFFEDF7F7), child: Text(q['student'][0], style: const TextStyle(color: Color(0xFF005F61)))),
                            const SizedBox(width: 10),
                            Text(q['student'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(q['question'], style: const TextStyle(fontFamily: 'Cairo')),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: q['isReplied'] ? null : () => _openReplyBottomSheet(index),
                            icon: Icon(q['isReplied'] ? Icons.check_circle : Icons.reply_rounded),
                            label: Text(q['isReplied'] ? 'تم الرد' : 'رد الآن'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-20,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20,),
                        // IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), 
                        // onPressed: () { Navigator.pushNamed(context, Routes.TeacherMainWrapper);}),
                        const Text('أسئلة الطلاب', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
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