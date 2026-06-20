// lib/features/teacher/presentation/screens/dashboard/teacher_questions_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherQuestionsScreen extends StatefulWidget {
  const TeacherQuestionsScreen({super.key});

  @override
  State<TeacherQuestionsScreen> createState() => _TeacherQuestionsScreenState();
}

class _TeacherQuestionsScreenState extends State<TeacherQuestionsScreen> {
  
  // دالة فتح صندوق كتابة الرد الأكاديمي للطالب
  void _openReplyBottomSheet(Map<String, dynamic> questionData) {
    final TextEditingController replyController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إرسال رد للطالب', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
              const SizedBox(height: 15),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Text(questionData['question'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5))),
              const SizedBox(height: 20),
              TextField(
                controller: replyController,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5),
                decoration: InputDecoration(hintText: 'اكتب ردك الأكاديمي هنا...', hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF005F61)))),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (replyController.text.trim().isNotEmpty) {
                      // 👈 استخدام الـ context الأصلي الممرر بنجاح للوصول للـ Cubit
                      BlocProvider.of<TeacherCubit>(context).replyToQuestion(questionData['id'], replyController.text.trim());
                      Navigator.pop(sheetContext); // 👈 إغلاق الشيت بسياقه المخصص والأمن
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الرد للطالب بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF005F61)));
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  label: const Text('إرسال الرد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.18;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. ترويسة الشاشة الثابتة هندسياً ومنع الوميض البصري ====================
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight - 20,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text('أسئلة الطلاب', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================== 2. منطقة عرض الأسئلة التفاعلية حياً من السيرفر ====================
            Positioned.fill(
              child: BlocBuilder<TeacherCubit, TeacherState>(
                builder: (context, state) {
                  if (state is TeacherLoading || state is TeacherInitial) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
                  }
                  
                  if (state is TeacherError) {
                    return Center(child: Text(state.message, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 15)));
                  }

                  if (state is TeacherLoaded) {
                    final questions = state.questions;

                    if (questions.isEmpty) {
                      return const Center(child: Text('لا توجد أسئلة من الطلاب حالياً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, headerHeight + 10, 20, 100),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final bool isReplied = q['isReplied'] ?? false;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(radius: 18, backgroundColor: Color(0xFFEDF7F7), child: Icon(Icons.person_outline_rounded, color: Color(0xFF005F61), size: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(q['studentName'] ?? 'طالب', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain))),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isReplied ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(8)), child: Text(isReplied ? 'تم الرد' : 'بانتظار ردك', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: isReplied ? const Color(0xFF27AE60) : Colors.redAccent))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(q['question'] ?? '', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey[800], height: 1.5)),
                              
                              // 💎 حقن وعرض نص الإجابة السحابية للمعلم في حالة تم الرد بنجاح 💎
                              if (isReplied && q['reply'] != null && q['reply'].toString().trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4FBF7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF27AE60).withAlpha((0.15 * 255).toInt())),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF27AE60), size: 16),
                                          SizedBox(width: 6),
                                          Text('ردك الأكاديمي المعتمد:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(q['reply'], style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.grey[800], height: 1.5)),
                                    ],
                                  ),
                                ),
                              ],

                              if (!isReplied) ...[
                                const SizedBox(height: 16),
                                SizedBox(width: double.infinity, height: 40, child: OutlinedButton.icon(onPressed: () => _openReplyBottomSheet(q), icon: const Icon(Icons.reply_rounded, size: 16), label: const Text('إرسال رد', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF005F61), side: const BorderSide(color: Color(0xFF005F61)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}