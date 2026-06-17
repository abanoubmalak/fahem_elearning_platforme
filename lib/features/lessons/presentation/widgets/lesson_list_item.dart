// lib/features/lessons/widgets/lesson_list_item.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class LessonListItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onWatchVideo;
  final VoidCallback onTakeQuiz;
  final VoidCallback onViewSummary; // الإجراء الجديد المضاف

  const LessonListItem({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onWatchVideo,
    required this.onTakeQuiz,
    required this.onViewSummary, // تمريره في الـ Constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // السطر العلوي: حالة الدرس وعنوانه
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isCompleted ? AppColors.primary : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // السطر السفلي: أزرار المحتوى الثلاثية التفاعلية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. زر فيديو الدرس
              Center(
                child: Expanded(
                  child: OutlinedButton(
                    onPressed: onWatchVideo,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 18),
                        SizedBox(height: 4),
                        Text(
                          'فيديو\nالدرس', 
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 2. زر بدء الاختبار
              Center(
                child: Expanded(
                  child: ElevatedButton(
                    onPressed: onTakeQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  AppColors.primaryTeal, // لون ذهبي معتمد للتقييم والاختبارات
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 18, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          '   بدء\nالاختبار', 
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 3. زر ملخص الدرس (الزر الجديد)
              Center(
                child: Expanded(
                  child: OutlinedButton(
                    onPressed: onViewSummary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF007A7C), // درجة لونية فيروزية داكنة منسقة للملخصات
                      side: const BorderSide(color: Color(0xFF007A7C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 18),
                        SizedBox(height: 4),
                        Text(
                          'ملخص\nالدرس', 
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}