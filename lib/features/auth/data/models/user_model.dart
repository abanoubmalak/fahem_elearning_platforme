import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;         
  final String? grade;       
  final String? term;       
  final String otpCode;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.grade,
    this.term,
    required this.otpCode,
    required this.isActive,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (grade != null) 'grade': grade,
      if (term != null) 'term': term,
      'otp_code': otpCode,
      'is_active': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}