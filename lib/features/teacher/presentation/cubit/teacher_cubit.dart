// lib/features/teacher/presentation/cubit/teacher_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  StreamSubscription? _profileSubscription;
  StreamSubscription? _questionsSubscription;
  StreamSubscription? _transactionsSubscription;

  final String _currentTeacherId = "TEACHER_CURRENT_UID";

  void fetchTeacherDashboard() {
    emit(TeacherLoading());
    _profileSubscription?.cancel();

    try {
      _profileSubscription = FirebaseFirestore.instance
          .collection('teachers')
          .doc(_currentTeacherId)
          .snapshots()
          .listen((profileDoc) {
            
        if (!profileDoc.exists) {
          emit(TeacherError(message: 'مستند المعلم غير موجود في الفايربيز ⏳'));
          return;
        }

        try {
          final data = profileDoc.data()!;
          
          final Map<String, dynamic> safeProfile = {
            'name': data['name'] ?? 'معلم غير محدد',
            'specialty': data['specialty'] ?? 'غير محدد',
            'availableBalance': (data['availableBalance'] ?? 0).toDouble(),
            'pendingBalance': (data['pendingBalance'] ?? 0).toDouble(),
            'totalStudents': (data['totalStudents'] ?? 0).toInt(),
            'averageScore': (data['averageScore'] ?? 0).toDouble(),
            'assignedCourses': data['assignedCourses'] ?? [],
          };

          _questionsSubscription?.cancel();
          _questionsSubscription = FirebaseFirestore.instance
              .collection('teacher_questions')
              .where('teacherId', isEqualTo: _currentTeacherId)
              .snapshots()
              .listen((questionsSnap) {
                
            final questions = questionsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

            _transactionsSubscription?.cancel();
            _transactionsSubscription = FirebaseFirestore.instance
                .collection('teacher_transactions')
                .where('teacherId', isEqualTo: _currentTeacherId)
                .snapshots()
                .listen((transSnap) {
                  
              final transactions = transSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

              emit(TeacherLoaded(
                teacherProfile: safeProfile,
                questions: questions,
                transactions: transactions,
              ));
            });
          });
          
        } catch (castingError) {
          emit(TeacherError(message: 'خطأ في مطابقة أنواع البيانات: $castingError'));
        }

      }, onError: (error) {
        emit(TeacherError(message: 'حدث خطأ أثناء المزامنة: $error'));
      });
    } catch (e) {
      emit(TeacherError(message: 'فشل الاتصال بالخادم: $e'));
    }
  }

  // 👈 دالة الرد المعتمدة رسمياً في الكوبيت
  Future<void> replyToQuestion(String questionId, String replyText) async {
    try {
      await FirebaseFirestore.instance.collection('teacher_questions').doc(questionId).update({
        'reply': replyText,
        'isReplied': true,
      });
    } catch (e) {
      debugPrint('❌ فشل إرسال الرد: $e');
    }
  }

  // 👈 دالة سحب الأرباح المعتمدة رسمياً في الكوبيت
  Future<void> requestWithdrawal(double amount, String method) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('teachers').doc(_currentTeacherId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentAvailable = snapshot.data()?['availableBalance'] ?? 0.0;
        final currentPending = snapshot.data()?['pendingBalance'] ?? 0.0;

        if (currentAvailable >= amount) {
          transaction.update(docRef, {
            'availableBalance': currentAvailable - amount,
            'pendingBalance': currentPending + amount,
          });

          transaction.set(FirebaseFirestore.instance.collection('withdrawal_requests').doc(), {
            'teacherId': _currentTeacherId,
            'amount': amount,
            'method': method,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          throw 'الرصيد غير كافٍ';
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
}