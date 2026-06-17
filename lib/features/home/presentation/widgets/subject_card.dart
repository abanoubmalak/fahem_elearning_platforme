// lib/features/home/widgets/subject_card.dart
import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final double progress; // نسبة التقدم من 0.0 إلى 1.0
  final IconData icon;

  const SubjectCard({
    super.key,
    required this.title,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة المادة الخلفية
          Icon(icon, size: 35, color: const Color(0xFF269A9E)),
          const SizedBox(height: 8),
          
          // اسم المادة
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF454545),
            ),
          ),
          const SizedBox(height: 8),
          
          // نسبة التقدم وشريط التحميل
          Row(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF269A9E)),
                    minHeight: 6,
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