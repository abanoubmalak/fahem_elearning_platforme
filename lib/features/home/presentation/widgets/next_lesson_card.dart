// lib/features/home/widgets/next_lesson_card.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class NextLessonCard extends StatelessWidget {
  final String subjectName;
  final String lessonTitle;
  final IconData subjectIcon;

  const NextLessonCard({
    super.key,
    required this.subjectName,
    required this.lessonTitle,
    required this.subjectIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.commonShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المادة بلون التطبيق
                Text(
                  subjectName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                // اسم الدرس
                Text(
                  lessonTitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 15),
                // زر البدء الفيروزي
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    elevation: 0, // تصميم مسطح (Flat)
                  ),
                  child: const Text(
                    'بدء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // الأيقونة الكبيرة الجانبية للمادة
          Icon(subjectIcon, size: 70, color: AppColors.primary),
        ],
      ),
    );
  }
}