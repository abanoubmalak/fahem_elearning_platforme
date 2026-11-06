import 'dart:async'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static const Map<String, String> _firestoreSubjectIdMap = {
    'ar': 'arabic',
  };

  String _firestoreSubjectId(String localId) {
    return _firestoreSubjectIdMap[localId] ?? localId;
  }

  String _stageCodeFromGrade(String? grade) {
    if (grade == null) return 'g1';
    if (grade.contains('الثاني الإعدادي')) return 'g2';
    if (grade.contains('الثالث الإعدادي')) return 'g3';
    return 'g1';
  }

  void fetchSyllabus({
    required String subjectId,
    required String term,
    String? studentGrade, 
  }) async {
    emit(SubjectDetailsLoading());

    try {
      final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      String stageCode = _stageCodeFromGrade(studentGrade);
      String termCode = term == 'الترم الثاني' ? 't2' : 't1';
      String firestoreSubjectId = _firestoreSubjectId(subjectId);
      String docId = '${firestoreSubjectId}_${stageCode}_$termCode';

      DocumentSnapshot contentDoc = await firestore
          .collection('subjects_content')
          .doc(docId) 
          .get();

      if (!contentDoc.exists) {
        emit(SubjectDetailsError(message: 'المحتوى غير موجود '));
        return;
      }

      final data = contentDoc.data() as Map<String, dynamic>;
      List<dynamic> units = List.from(data['units'] ?? []);

      QuerySnapshot progressSnap = await firestore
          .collection('student_progress')
          .where('studentId', isEqualTo: studentId)
          .where('subjectId', isEqualTo: subjectId)
          .get();

      Set<String> completedLessons = {};
      for (var doc in progressSnap.docs) {
        final pData = doc.data() as Map<String, dynamic>;
        if (pData['isCompleted'] == true) {
          completedLessons.add(pData['lessonTitle'] ?? '');
        }
      }

      for (var unit in units) {
        List<dynamic> lessons = List.from(unit['lessons'] ?? []);
        for (var lesson in lessons) {
          lesson['isCompleted'] = completedLessons.contains(lesson['title']);
        }
        unit['lessons'] = lessons;
      }

      emit(SubjectDetailsLoaded(units: units));
      
    } catch (e) {
      emit(SubjectDetailsError(message: 'حدث خطأ: $e'));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}