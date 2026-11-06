import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';

abstract class TeacherState {}

class TeacherInitial extends TeacherState {}
class TeacherLoading extends TeacherState {}
class TeacherLoaded extends TeacherState {
  final Map<String, dynamic> teacherProfile;
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> transactions;

  TeacherLoaded({
    required this.teacherProfile,
    required this.questions,
    required this.transactions,
  });
}
class TeacherError extends TeacherState {
  final String message;
  TeacherError({required this.message});
}

class TeacherCubit extends Cubit<TeacherState> {
  TeacherCubit() : super(TeacherInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _profileSubscription;
  StreamSubscription? _questionsSubscription;
  StreamSubscription? _transactionsSubscription;

  Map<String, dynamic>? _profileCache;
  List<Map<String, dynamic>> _questionsCache = [];
  List<Map<String, dynamic>> _transactionsCache = [];

  String get _currentTeacherId => _auth.currentUser?.uid ?? '';

  void fetchTeacherDashboard() {
    if (_currentTeacherId.isEmpty) {
      emit(TeacherError(message: 'لم يتم العثور على جلسة معلم نشطة ❌'));
      return;
    }

    emit(TeacherLoading());

    _profileSubscription?.cancel();
    _questionsSubscription?.cancel();
    _transactionsSubscription?.cancel();

    try {
      _profileSubscription = _firestore
          .collection('teachers')
          .doc(_currentTeacherId)
          .snapshots()
          .listen((profileDoc) {
            
        debugPrint('--- [Debug] Firestore Path: teachers/$_currentTeacherId ---');
        debugPrint('--- [Debug] Data Exists: ${profileDoc.exists} ---');

        if (!profileDoc.exists || profileDoc.data() == null) {
          emit(TeacherError(message: 'مستند المعلم غير موجود في الفايربيز ⏳'));
          return;
        }

        try {
          final data = profileDoc.data()!;
          
          _profileCache = {
            'name': data['name'] ?? 'معلم غير محدد',
            'specialty': data['specialty'] ?? 'غير محدد',
            'availableBalance': (data['availableBalance'] ?? 0).toDouble(),
            'pendingBalance': (data['pendingBalance'] ?? 0).toDouble(),
            'totalStudents': (data['totalStudents'] ?? 0).toInt(),
            'averageScore': (data['averageScore'] ?? 0.0).toDouble(),
            'excellentCount': data['excellentCount'], 
            'goodCount': data['goodCount'],
            'weakCount': data['weakCount'],
            'assignedCourses': data['assignedCourses'] ?? [],
          };

          _emitLoadedIfReady(); 
          
        } catch (castingError) {
          emit(TeacherError(message: 'خطأ في مطابقة أنواع البيانات: $castingError'));
        }
      }, onError: (error) {
        emit(TeacherError(message: 'حدث خطأ أثناء مزامنة الملف الشخصي: $error'));
      });

      _questionsSubscription = _firestore
          .collection('teacher_questions')
          .where('teacherId', isEqualTo: _currentTeacherId)
          .snapshots()
          .listen((questionsSnap) {
            
        _questionsCache = questionsSnap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        _emitLoadedIfReady();
      }, onError: (error) {
        emit(TeacherError(message: 'حدث خطأ أثناء مزامنة أسئلة الطلاب: $error'));
      });

      _transactionsSubscription = _firestore
          .collection('transactions') 
          .where('teacherId', isEqualTo: _currentTeacherId)
          .snapshots()
          .listen((transSnap) {
            
        _transactionsCache = transSnap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        _emitLoadedIfReady();
      }, onError: (error) {
        emit(TeacherError(message: 'حدث خطأ أثناء مزامنة كشف الحساب المالي: $error'));
      });

    } catch (e) {
      emit(TeacherError(message: 'فشل الاتصال بالخادم السحابي: $e'));
    }
  }

  void _emitLoadedIfReady() {
    if (_profileCache != null && !isClosed) {
      emit(TeacherLoaded(
        teacherProfile: _profileCache!,
        questions: _questionsCache,
        transactions: _transactionsCache,
      ));
    }
  }

  Future<void> replyToQuestion(String questionId, String replyText) async {
    try {
      await _firestore.collection('teacher_questions').doc(questionId).update({
        'reply': replyText.trim(),
        'isReplied': true,
      });
    } catch (e) {
      debugPrint('❌ فشل إرسال الرد: $e');
    }
  }

  Future<void> requestWithdrawal(double amount, String method) async {
    if (_currentTeacherId.isEmpty) return;

    try {
      final docRef = _firestore.collection('teachers').doc(_currentTeacherId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentAvailable = (snapshot.data()?['availableBalance'] ?? 0.0).toDouble();
        final currentPending = (snapshot.data()?['pendingBalance'] ?? 0.0).toDouble();

        if (currentAvailable >= amount) {
          transaction.update(docRef, {
            'availableBalance': currentAvailable - amount,
            'pendingBalance': currentPending + amount,
          });

          transaction.set(_firestore.collection('withdrawal_requests').doc(), {
            'teacherId': _currentTeacherId,
            'teacherName': snapshot.data()?['name'] ?? 'معلم فاهم',
            'amount': amount,
            'method': method,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(), 
          });
        } else {
          throw 'الرصيد المتاح بالمحفظة غير كافٍ لإتمام العملية ⚠️';
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _questionsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }




  Future<void> updateTeacherStats(String teacherId, double newScore) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DocumentReference teacherRef = firestore.collection('teachers').doc(teacherId);

  await firestore.runTransaction((transaction) async {
    DocumentSnapshot teacherSnapshot = await transaction.get(teacherRef);
    
    if (!teacherSnapshot.exists) return;

    Map<String, dynamic> data = teacherSnapshot.data() as Map<String, dynamic>;
    
    int totalStudents = (data['totalStudents'] ?? 0);
    double currentAverage = (data['averageScore'] ?? 0.0).toDouble();
    int excellentCount = (data['excellentCount'] ?? 0);
    int goodCount = (data['goodCount'] ?? 0);
    int weakCount = (data['weakCount'] ?? 0);

    int newTotalStudents = totalStudents + 1;
    double newAverage = ((currentAverage * totalStudents) + newScore) / newTotalStudents;
    
    int newExcellent = excellentCount;
    int newGood = goodCount;
    int newWeak = weakCount;

    if (newScore >= 8.5) {
      newExcellent++;
    } else if (newScore >= 7.5) {
      newGood++;
    } else {
      newWeak++;
    }

    transaction.update(teacherRef, {
      'totalStudents': newTotalStudents,
      'averageScore': newAverage,
      'excellentCount': newExcellent,
      'goodCount': newGood,
      'weakCount': newWeak,
    });
  });
}

Future<void> addUnit({
  required String subjectId,
  required String term,
  required String unitName,
}) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('subjects_content')
        .where('subjectId', isEqualTo: subjectId)
        .where('term', isEqualTo: term)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;

      final Map<String, dynamic> newUnit = {
        'title': unitName,
        'lessons': [],
        'quiz': [],    
        'summaries': [], 
      };

      await FirebaseFirestore.instance
          .collection('subjects_content')
          .doc(docId)
          .update({
        'units': FieldValue.arrayUnion([newUnit]),
      });
      
    } else {
      debugPrint("خطأ: لم يتم العثور على مستند المادة لهذا الترم");
    }
  } catch (e) {
    debugPrint("حدث خطأ أثناء إضافة الوحدة: $e");
  }
}


}