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

  static const Map<String, String> reverseSubjectCodes = {
    'arabic': 'لغة عربية',
    'english': 'لغة إنجليزية',
    'math': 'رياضيات',
    'sci': 'علوم',
    'social': 'دراسات اجتماعية',
  };
  AdminCubit() : super(AdminInitial());



StreamSubscription? _teachersSub;
  StreamSubscription? _studentsSub;
  StreamSubscription? _parentsSub;
  StreamSubscription? _payoutsSub;
  StreamSubscription? _transactionsSub;

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

              // 👈 الاستماع الحي لكل المعاملات المالية لحساب صافي أرباح المنصة الحقيقي
              _transactionsSub = FirebaseFirestore.instance.collection('transactions').snapshots().listen((transactionsSnap) {
                double totalPlatformEarnings = 0.0;
                for (var doc in transactionsSnap.docs) {
                  totalPlatformEarnings += (doc.data()['platformProfit'] ?? 0.0).toDouble();
                }

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
                      'platformNetEarnings': totalPlatformEarnings,
                    },
                  ));
                }
              });
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


  Future<void> rejectWithdrawalRequest({required String requestId, required String teacherId, required double amount}) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(FirebaseFirestore.instance.collection('withdrawal_requests').doc(requestId), {'status': 'rejected'});
      // إرجاع المبلغ من "معلّق" إلى "متاح" تاني عشان المعلم يقدر يطلب سحبه تاني
      batch.update(FirebaseFirestore.instance.collection('teachers').doc(teacherId), {
        'pendingBalance': FieldValue.increment(-amount),
        'availableBalance': FieldValue.increment(amount),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('Error rejecting payout: $e');
    }
  }

  Future<void> addStudent(Map<String, dynamic> data) async => await FirebaseFirestore.instance.collection('students').add(data);
Future<String?> updateStudentData({
  required String studentId,
  required Map<String, dynamic> studentData,
}) async {
  try {
    await FirebaseFirestore.instance.collection('students').doc(studentId).update({
      'name': studentData['name'],
      'email': studentData['email'],
      'phone': studentData['phone'],
      'stage': studentData['stage'],
    });
    return null; // نجاح
  } catch (e) {
    return 'حدث خطأ أثناء التعديل: $e';
  }
}


Future<String?> addTeacherWithValidation(
    Map<String, dynamic> data,
) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('teachers').get();

    final newCourses =
        List<Map<String, dynamic>>.from(data['assignedCourses'] ?? []);

    for (var doc in snapshot.docs) {
      final existingCourses =
          List<Map<String, dynamic>>.from(
        doc.data()['assignedCourses'] ?? [],
      );

      for (var existing in existingCourses) {
        for (var newCourse in newCourses) {
          if (existing['subject'] == newCourse['subject'] &&
              existing['stage'] == newCourse['stage'] &&
              existing['term'] == newCourse['term']) {
            

return
    'المادة ${reverseSubjectCodes[newCourse['subject']] ?? newCourse['subject']} محجوزة بالفعل لمعلم آخر في ${newCourse['stage']} - ${newCourse['term']}';
          }
        }
      }
    }

    await FirebaseFirestore.instance
        .collection('teachers')
        .doc(data['uid'])
        .set(data);

    return null;
  } catch (e) {
    return e.toString();
  }
} Future<void> addParent(Map<String, dynamic> data) async => await FirebaseFirestore.instance.collection('parents').add(data); // 👈 دالة إضافة ولي الأمر

Future<String?> updateParentData({
  required String parentId,
  required Map<String, dynamic> parentData,
}) async {
  try {
    await FirebaseFirestore.instance.collection('parents').doc(parentId).update({
      'name': parentData['name'],
      'email': parentData['email'],
    });
    return null; // نجاح
  } catch (e) {
    return 'حدث خطأ أثناء التعديل: $e';
  }
}

Future<String?> deleteParent(String parentId) async {
  try {
    await FirebaseFirestore.instance.collection('parents').doc(parentId).delete();
    return null; // نجاح
  } catch (e) {
    return 'حدث خطأ أثناء الحذف: $e';
  }
}


Future<String?> updateTeacherData({
  required String teacherId,
  required List<Map<String, dynamic>> newCourses,
  required Map<String, dynamic> teacherBasicData,
}) async {
  try {
    // نقوم بتحديث البيانات الأساسية والمواد
    await FirebaseFirestore.instance.collection('teachers').doc(teacherId).update({
      'name': teacherBasicData['name'],
      'phone': teacherBasicData['phone'],
      'email': teacherBasicData['email'],
      'specialty': teacherBasicData['specialty'],
      'assignedCourses': newCourses, // تحديث المصفوفة بالكامل
    });
    return null; // نجاح
  } catch (e) {
    return 'حدث خطأ أثناء التعديل: $e';
  }
}


@override
  Future<void> close() {
    _teachersSub?.cancel();
    _studentsSub?.cancel();
    _parentsSub?.cancel();
    _payoutsSub?.cancel();
    _transactionsSub?.cancel();
    return super.close();
  }
}