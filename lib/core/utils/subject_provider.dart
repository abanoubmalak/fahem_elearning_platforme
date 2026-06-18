// lib/core/utils/subject_provider.dart
import 'package:flutter/material.dart';
import '../../features/home/data/models/subject_model.dart';

class SubjectProvider {
  // دالة ذكية ترجع المواد بناءً على الصف الدراسي للطالب
  static List<SubjectModel> getSubjectsByGrade(String studentGrade) {
    
    // قائمة المواد الأساسية (للصفوف الابتدائية الأولى)
    List<SubjectModel> primarySubjects = [
      SubjectModel(id: 'ar', title: 'اللغة العربية', progress: 0.0, icon: Icons.menu_book_rounded),
      SubjectModel(id: 'en', title: 'اللغة الانجليزية', progress: 0.0, icon: Icons.g_translate_rounded),
      SubjectModel(id: 'math', title: 'الرياضيات', progress: 0.0, icon: Icons.calculate_rounded),
    ];

    // قائمة المواد الإضافية (للصفوف الأعلى)
    List<SubjectModel> advancedSubjects = [
      SubjectModel(id: 'sci', title: 'العلوم', progress: 0.0, icon: Icons.science_rounded),
      SubjectModel(id: 'soc', title: 'الدراسات الاجتماعية', progress: 0.0, icon: Icons.public_rounded),
    ];

    // الفلترة المنطقية: التحقق من وجود الكلمات الدلالية للصفوف من الأول للثالث
    if (studentGrade.contains('الأول الابتدائي') || 
        studentGrade.contains('الثاني الابتدائي') || 
        studentGrade.contains('الثالث الابتدائي')) {
      return primarySubjects; // يرجع 3 مواد فقط
    } else {
      // دمج القائمتين للصفوف الأعلى
      return [...primarySubjects, ...advancedSubjects]; // يرجع 5 مواد
    }
  }
}