// lib/features/lessons/presentation/cubit/subject_details_cubit.dart
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
void fetchSyllabus({required String subjectId, required String term}) async {
    emit(SubjectDetailsLoading());

    try {
      final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 💎 التعديل المنطقي: تحويل الترم إلى الصيغة المكتوبة في الداتابيز 💎
      // لو الترم "الترم الثاني" خليه "g1_t2" (أو حسب ما هو مخزن عندك)
      String termCode = term == 'الترم الثاني' ? 'g1_t2' : 'g1_t1'; 
      String docId = '${subjectId}_$termCode'; 

      // 1. جلب محتوى المنهج الأساسي
      DocumentSnapshot contentDoc = await firestore
          .collection('subjects_content')
          .doc(docId) // استخدام المعرف المصحح
          .get();

      if (!contentDoc.exists) {
        emit(SubjectDetailsError(message: 'المحتوى غير موجود (جربت: $docId) ⏳'));
        return;
      }

      final data = contentDoc.data() as Map<String, dynamic>;
      List<dynamic> units = List.from(data['units'] ?? []);

      // 2. جلب تقدم الطالب الحالي
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

      // 3. دمج البيانات
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