// lib/features/teacher/presentation/cubit/teacher_academic_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TeacherAcademicState {}

class AcademicInitial extends TeacherAcademicState {}
class AcademicLoading extends TeacherAcademicState {}
class AcademicLoaded extends TeacherAcademicState {
  final List<dynamic> units;
  AcademicLoaded({required this.units});
}
class AcademicError extends TeacherAcademicState {
  final String message;
  AcademicError({required this.message});
}

class TeacherAcademicCubit extends Cubit<TeacherAcademicState> {
  TeacherAcademicCubit() : super(AcademicInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _academicSubscription;

  // دالة مساعدة لتوليد الـ ID الرسمي للمستند سحابياً
  String _resolveSubjectDocId(String subjectId, String stageName, String term) {
    if (subjectId.contains('_')) return subjectId; 

    String stageCode = 'g1';
    if (stageName.contains('الثاني')) stageCode = 'g2';
    if (stageName.contains('الثالث')) stageCode = 'g3';
    
    String termCode = 't2';
    if (term.contains('الأول')) termCode = 't1';
    
    return '${subjectId}_${stageCode}_${termCode}';
  }

  // مراقبة وحدات المنهج ودروسه حياً من السيرفر
  void listenToSyllabus({required String subjectId, String stageName = 'الصف الأول الإعدادي', required String term}) {
    emit(AcademicLoading());
    _academicSubscription?.cancel();

    final String docId = _resolveSubjectDocId(subjectId, stageName, term);

    _academicSubscription = _firestore
        .collection('subjects_content')
        .doc(docId)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final List<dynamic> units = docSnapshot.data()?['units'] ?? [];
        emit(AcademicLoaded(units: units));
      } else {
        emit(AcademicLoaded(units: const [])); 
      }
    }, onError: (err) {
      emit(AcademicError(message: 'فشل مزامنة المنهج حياً: $err'));
    });
  }

  // دالة مساعدة عامة لتحديث مصفوفة الوحدات بالكامل
  Future<void> _updateSyllabusInFirebase(String subjectId, String stageName, String term, List<dynamic> updatedUnits) async {
    final String docId = _resolveSubjectDocId(subjectId, stageName, term);
    await _firestore
        .collection('subjects_content')
        .doc(docId)
        .set({'units': updatedUnits}, SetOptions(merge: true));
  }

  // إضافة وحدة دراسية جديدة للمنهج
  Future<void> addUnit({
    required String subjectId,
    String stageName = 'الصف الأول الإعدادي',
    required String term,
    required String unitName,
  }) async {
    final String docId = _resolveSubjectDocId(subjectId, stageName, term);
    try {
      await _firestore.collection('subjects_content').doc(docId).update({
        'units': FieldValue.arrayUnion([{
          'title': unitName,
          'lessons': [],
        }])
      });
    } catch (e) {
      debugPrint("خطأ في إضافة الوحدة: $e");
    }
  }

  // إضافة درس جديد للمنهج مع تهيئة حقل الـ quiz
  Future<void> addLesson({
    required String subjectId,
    String stageName = 'الصف الأول الإعدادي',
    required String term,
    required String unitTitle,
    required String lessonName,
  }) async {
    final String docId = _resolveSubjectDocId(subjectId, stageName, term);
    final docRef = _firestore.collection('subjects_content').doc(docId);
    
    try {
      final doc = await docRef.get();
      if (!doc.exists) return;
      
      List<dynamic> units = List.from(doc.data()?['units'] ?? []);
      
      final updatedUnits = units.map((unit) {
        if (unit['title'] == unitTitle) {
          final lessons = List.from(unit['lessons'] ?? []);
          lessons.add({
            'title': lessonName,
            'videoUrl': '',
            'summaries': [],
            'quiz': [], // 💎 تم التحديث هنا لتهيئة حقل الاختبار بالاسم الصحيح
            'isCompleted': false,
          });
          return {...unit, 'lessons': lessons};
        }
        return unit;
      }).toList();

      await docRef.update({'units': updatedUnits});
    } catch (e) {
      debugPrint("خطأ في إضافة الدرس: $e");
    }
  }

  // تحديث محتويات الدرس (الفيديو، الملخص، أو الكويز) سحابياً
  Future<void> updateLessonContent({
    required String subjectId,
    String stageName = 'الصف الأول الإعدادي',
    required String term,
    required String unitTitle,
    required String lessonTitle,
    required String contentType,
    required dynamic contentData,
  }) async {
    final String docId = _resolveSubjectDocId(subjectId, stageName, term);
    final docRef = _firestore.collection('subjects_content').doc(docId);

    try {
      final doc = await docRef.get();
      if (!doc.exists) return;

      List<dynamic> units = List.from(doc.data()?['units'] ?? []);

      final updatedUnits = units.map((unit) {
        if (unit['title'] == unitTitle) {
          final lessons = List.from(unit['lessons'] ?? []);
          final updatedLessons = lessons.map((lesson) {
            if (lesson['title'] == lessonTitle) {
              if (contentType == 'video') {
                return {...lesson, 'videoUrl': contentData};
              } else if (contentType == 'summary') {
                return {...lesson, 'summaries': contentData}; 
              } else if (contentType == 'quiz') {
                return {...lesson, 'quiz': contentData}; // 💎 تم التحديث لتخزين مصفوفة الأسئلة داخل الحقل quiz مباشرة
              }
            }
            return lesson;
          }).toList();
          
          return {...unit, 'lessons': updatedLessons};
        }
        return unit;
      }).toList();

      await docRef.update({'units': updatedUnits});
      emit(AcademicLoaded(units: updatedUnits));
    } catch (e) {
      debugPrint("خطأ في تحديث محتوى الدرس: $e");
    }
  }

  @override
  Future<void> close() {
    _academicSubscription?.cancel();
    return super.close();
  }
}