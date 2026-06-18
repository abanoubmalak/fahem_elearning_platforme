// lib/features/home/data/models/subject_model.dart
import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String title;
  final double progress; 
  final IconData icon;

  SubjectModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.icon,
  });
}