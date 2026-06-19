// lib/features/admin/presentation/cubit/admin_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class AdminState {}
class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminLoaded extends AdminState {
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> parents; // 👈 إضافة أولياء الأمور
  final List<Map<String, dynamic>> payoutRequests;
  final Map<String, dynamic> financials;

  AdminLoaded({
    required this.teachers,
    required this.students,
    required this.parents,
    required this.payoutRequests,
    required this.financials,
  });
}
class AdminError extends AdminState {
  final String message;
  AdminError({required this.message});
}

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());

  StreamSubscription? _teachersSub;
  StreamSubscription? _studentsSub;
  StreamSubscription? _parentsSub;
  StreamSubscription? _payoutsSub;

  void listenToPlatformLive() {
    emit(AdminLoading());

    try {
      _teachersSub = FirebaseFirestore.instance.collection('teachers').snapshots().listen((teachersSnap) {
        final teachers = teachersSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        
        _studentsSub = FirebaseFirestore.instance.collection('students').snapshots().listen((studentsSnap) {
          final students = studentsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

          // 👈 الاستماع الحي لبيانات أولياء الأمور
          _parentsSub = FirebaseFirestore.instance.collection('parents').snapshots().listen((parentsSnap) {
            final parents = parentsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

            _payoutsSub = FirebaseFirestore.instance.collection('withdrawal_requests').where('status', isEqualTo: 'pending').snapshots().listen((payoutsSnap) {
              final payouts = payoutsSnap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

              double totalTeachersPending = 0.0;
              for (var t in teachers) {
                totalTeachersPending += (t['pendingBalance'] ?? 0.0).toDouble();
              }

              if (!isClosed) {
                emit(AdminLoaded(
                  teachers: teachers,
                  students: students,
                  parents: parents,
                  payoutRequests: payouts,
                  financials: {
                    'totalTeachersHolding': totalTeachersPending,
                    'platformNetEarnings': (students.length * 150.0), 
                  },
                ));
              }
            });
          });
        });
      }, onError: (e) {
        if (!isClosed) emit(AdminError(message: 'خطأ في الاتصال بالسيرفر: $e'));
      });
    } catch (e) {
      if (!isClosed) emit(AdminError(message: 'حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> toggleUserStatus({required String collection, required String userId, required bool currentStatus}) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(userId).update({'isActive': !currentStatus});
    } catch (e) {
      debugPrint('Error toggling status: $e');
    }
  }

  Future<void> approveWithdrawalRequest({required String requestId, required String teacherId, required double amount}) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(FirebaseFirestore.instance.collection('withdrawal_requests').doc(requestId), {'status': 'approved'});
      batch.update(FirebaseFirestore.instance.collection('teachers').doc(teacherId), {'pendingBalance': FieldValue.increment(-amount)});
      await batch.commit();
    } catch (e) {
      debugPrint('Error approving payout: $e');
    }
  }

  Future<void> addStudent(Map<String, dynamic> data) async => await FirebaseFirestore.instance.collection('students').add(data);
  Future<void> addTeacher(Map<String, dynamic> data) async => await FirebaseFirestore.instance.collection('teachers').add(data);
  Future<void> addParent(Map<String, dynamic> data) async => await FirebaseFirestore.instance.collection('parents').add(data); // 👈 دالة إضافة ولي الأمر

  @override
  Future<void> close() {
    _teachersSub?.cancel();
    _studentsSub?.cancel();
    _parentsSub?.cancel();
    _payoutsSub?.cancel();
    return super.close();
  }
}