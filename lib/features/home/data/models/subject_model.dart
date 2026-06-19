// lib/features/home/data/models/subject_model.dart
import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String title;
  final double progress; 
  final IconData icon;
  
  // 👈 المتغيرات الجديدة للربط بنظام الدفع والفايربيز
  final String packageId; 
  final bool isUnlocked;  

  SubjectModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.icon,
    this.packageId = '',     // قيمة افتراضية عشان SubjectProvider ميضربش
    this.isUnlocked = false, // المادة مقفولة افتراضياً لحد ما الفايربيز يأكد الدفع
  });

  // 👈 دالة مساعدة (Helper Method) هتخلينا نحدث حالة المادة بسهولة جداً في الكوبيت
  SubjectModel copyWith({
    double? progress,
    String? packageId,
    bool? isUnlocked,
  }) {
    return SubjectModel(
      id: id,
      title: title,
      icon: icon,
      progress: progress ?? this.progress,
      packageId: packageId ?? this.packageId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}