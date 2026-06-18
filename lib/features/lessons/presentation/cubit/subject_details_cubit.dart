// lib/features/lessons/presentation/cubit/subject_details_cubit.dart
import 'dart:async'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class SubjectDetailsState {}

class SubjectDetailsInitial extends SubjectDetailsState {}
class SubjectDetailsLoading extends SubjectDetailsState {}
class SubjectDetailsLoaded extends SubjectDetailsState {
  final List<dynamic> units;
  SubjectDetailsLoaded({required this.units});
}
class SubjectDetailsError extends SubjectDetailsState {
  final String message;
  SubjectDetailsError({required this.message});
}

class SubjectDetailsCubit extends Cubit<SubjectDetailsState> {
  SubjectDetailsCubit() : super(SubjectDetailsInitial());

  StreamSubscription? _syllabusSubscription;

  void fetchSyllabus({required String subjectId, required String term}) {
    emit(SubjectDetailsLoading());

    _syllabusSubscription?.cancel();

    try {
      // 👈 استخدام البث الحي (snapshots) لتحديث الشاشة فوراً عند إعادة الاختبار
      _syllabusSubscription = FirebaseFirestore.instance
          .collection('subjects_content')
          .doc('${subjectId}_$term')
          .snapshots()
          .listen(
        (docSnapshot) {
          if (docSnapshot.exists) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            final List<dynamic> units = data['units'] ?? [];
            emit(SubjectDetailsLoaded(units: units));
          } else {
            emit(SubjectDetailsError(message: 'المحتوى الدراسي غير متوفر حالياً ⏳'));
          }
        },
        onError: (error) {
          emit(SubjectDetailsError(message: 'حدث خطأ أثناء المزامنة: $error'));
        },
      );
    } catch (e) {
      emit(SubjectDetailsError(message: 'فشل الاتصال بالسيرفر: $e'));
    }
  }

  @override
  Future<void> close() {
    _syllabusSubscription?.cancel();
    return super.close();
  }
}