// lib/features/teacher/presentation/cubit/teacher_academic_cubit.dart
import 'dart:async';
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

  StreamSubscription? _academicSubscription;

  // 👈 دالة مراقبة وحدات المنهج ودروسه حياً من السيرفر
  void listenToSyllabus({required String subjectId, required String term}) {
    emit(AcademicLoading());
    _academicSubscription?.cancel();

    _academicSubscription = FirebaseFirestore.instance
        .collection('subjects_content')
        .doc('${subjectId}_$term')
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final List<dynamic> units = docSnapshot.data()?['units'] ?? [];
        emit(AcademicLoaded(units: units));
      } else {
        emit(AcademicLoaded(units: const [])); // 👈 التعديل البرمجي الصحيح والمؤمن هنا
      }
    }, onError: (err) {
      emit(AcademicError(message: 'فشل مزامنة المنهج: $err'));
    });
  }

  // دالة مساعدة عامة لتحديث المصفوفة بالكامل في الفايربيز
  Future<void> _updateSyllabusInFirebase(String subjectId, String term, List<dynamic> updatedUnits) async {
    await FirebaseFirestore.instance
        .collection('subjects_content')
        .doc('${subjectId}_$term')
        .set({'units': updatedUnits}, SetOptions(merge: true));
  }

  // 1. دالة إضافة وحدة دراسية جديدة للمنهج
  Future<void> addUnit({required String subjectId, required String term, required String unitName, required List<dynamic> currentUnits}) async {
    final List<dynamic> updatedUnits = List.from(currentUnits);
    updatedUnits.add({
      'title': unitName,
      'lessons': [], 
    });
    await _updateSyllabusInFirebase(subjectId, term, updatedUnits);
  }

  // 2. دالة إضافة درس جديد بداخل وحدة معينة
  Future<void> addLesson({required String subjectId, required String term, required String unitTitle, required String lessonName, required List<dynamic> currentUnits}) async {
    final List<dynamic> updatedUnits = currentUnits.map((unit) {
      if (unit['title'] == unitTitle) {
        final List<dynamic> lessons = List.from(unit['lessons'] ?? []);
        lessons.add({
          'title': lessonName,
          'videoUrl': '',
          'summaries': [],
          'questions': [],
          'isCompleted': false,
        });
        return {...unit, 'lessons': lessons};
      }
      return unit;
    }).toList();
    await _updateSyllabusInFirebase(subjectId, term, updatedUnits);
  }

  // 3. دالة إضافة أو تحديث محتوى الدرس (فيديو، ملخص، أو كويز مدمج)
  Future<void> updateLessonContent({
    required String subjectId,
    required String term,
    required String unitTitle,
    required String lessonTitle,
    required String contentType, 
    required dynamic contentData, 
    required List<dynamic> currentUnits,
  }) async {
    final List<dynamic> updatedUnits = currentUnits.map((unit) {
      if (unit['title'] == unitTitle) {
        final List<dynamic> lessons = (unit['lessons'] as List).map((lesson) {
          if (lesson['title'] == lessonTitle) {
            if (contentType == 'video') {
              return {...lesson, 'videoUrl': contentData as String};
            } else if (contentType == 'summary') {
              return {...lesson, 'summaries': contentData as List<dynamic>};
            } else if (contentType == 'quiz') {
              return {...lesson, 'questions': contentData as List<dynamic>};
            }
          }
          return lesson;
        }).toList();
        return {...unit, 'lessons': lessons};
      }
      return unit;
    }).toList();
    await _updateSyllabusInFirebase(subjectId, term, updatedUnits);
  }

  @override
  Future<void> close() {
    _academicSubscription?.cancel();
    return super.close();
  }
}