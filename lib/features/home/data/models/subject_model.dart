import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String title;
  final double progress; 
  final IconData icon;
  
  final String packageId; 
  final bool isUnlocked;  

  SubjectModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.icon,
    this.packageId = '',     
    this.isUnlocked = false, 
  });

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