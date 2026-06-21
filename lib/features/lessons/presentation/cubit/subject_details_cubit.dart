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

  // 💎 نفس خريطة التحويل الموجودة في StudentCubit، لازم تتطابق بالظبط
  // عشان الـ docId اللي بيتجاب بيه المحتوى من subjects_content يطابق
  // نفس الـ packageId المستخدم في unlockedPackages.
  // مثال: مادة اللغة العربية id داخلي = 'ar' لكن المخزن في فايربيز 'arabic'.
  static const Map<String, String> _firestoreSubjectIdMap = {
    'ar': 'arabic',
  };

  String _firestoreSubjectId(String localId) {
    return _firestoreSubjectIdMap[localId] ?? localId;
  }

  // 💎 توليد كود الصف الدراسي (g1/g2/g3) من اسم الصف الحقيقي بدل التثبيت اليدوي
  String _stageCodeFromGrade(String? grade) {
    if (grade == null) return 'g1';
    if (grade.contains('الثاني الإعدادي')) return 'g2';
    if (grade.contains('الثالث الإعدادي')) return 'g3';
    return 'g1';
  }

  void fetchSyllabus({
    required String subjectId,
    required String term,
    String? studentGrade, // 👈 صف الطالب الحقيقي، اختياري للحفاظ على التوافق مع الاستدعاءات القديمة
  }) async {
    emit(SubjectDetailsLoading());

    try {
      final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 💎 التعديل المنطقي: توليد docId مطابق تماماً لما هو مستخدم في unlockedPackages
      String stageCode = _stageCodeFromGrade(studentGrade);
      String termCode = term == 'الترم الثاني' ? 't2' : 't1';
      String firestoreSubjectId = _firestoreSubjectId(subjectId);
      String docId = '${firestoreSubjectId}_${stageCode}_$termCode';

      // 1. جلب محتوى المنهج الأساسي
      DocumentSnapshot contentDoc = await firestore
          .collection('subjects_content')
          .doc(docId) // استخدام المعرف المصحح
          .get();

      if (!contentDoc.exists) {
        emit(SubjectDetailsError(message: 'المحتوى غير موجود '));
        return;
      }

      final data = contentDoc.data() as Map<String, dynamic>;
      List<dynamic> units = List.from(data['units'] ?? []);

      // 2. جلب تقدم الطالب الحالي (الاستعلام يتم بالـ id المحلي كما هو محفوظ من شاشات الدرس/الاختبار)
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