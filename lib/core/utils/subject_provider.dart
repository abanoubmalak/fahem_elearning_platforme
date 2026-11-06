import 'package:flutter/material.dart';
import '../../features/home/data/models/subject_model.dart';

class SubjectProvider {
  static List<SubjectModel> getSubjectsByGrade(String studentGrade) {
    
    List<SubjectModel> primarySubjects = [
      SubjectModel(id: 'ar', title: 'اللغة العربية', progress: 0.0, icon: Icons.menu_book_rounded),
      SubjectModel(id: 'en', title: 'اللغة الانجليزية', progress: 0.0, icon: Icons.g_translate_rounded),
      SubjectModel(id: 'math', title: 'الرياضيات', progress: 0.0, icon: Icons.calculate_rounded),
    ];

    List<SubjectModel> advancedSubjects = [
      SubjectModel(id: 'sci', title: 'العلوم', progress: 0.0, icon: Icons.science_rounded),
      SubjectModel(id: 'soc', title: 'الدراسات الاجتماعية', progress: 0.0, icon: Icons.public_rounded),
    ];

    if (studentGrade.contains('الأول الابتدائي') || 
        studentGrade.contains('الثاني الابتدائي') || 
        studentGrade.contains('الثالث الابتدائي')) {
      return primarySubjects; 
    } else {
      return [...primarySubjects, ...advancedSubjects]; 
    }
  }
}