// lib/features/parent/presentation/cubit/parent_cubit.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentState {
  final List<Map<String, dynamic>> children;
  final bool isLoading;
  final String? errorMessage;

  ParentState({
    required this.children,
    this.isLoading = false,
    this.errorMessage,
  });
}

class ParentCubit extends Cubit<ParentState> {
  ParentCubit() : super(ParentState(children: [], isLoading: false)) {
    loadParentDashboard();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _parentSubscription;
  StreamSubscription? _childrenSubscription;

  // 💎 كاونتر لضمان إن آخر استجابة فقط هي اللي تعمل emit (تجنّب Race Condition)
  int _fetchGeneration = 0;

  // 💎 حفظ آخر قائمة طلاب لمنع إعادة بناء الـ stream لو القائمة لم تتغير فعلياً
  List<dynamic>? _lastLinkedStudents;

  // 💎 الكتالوج الكامل للمواد لكل مرحلة
  static const Map<String, List<Map<String, String>>> _subjectsCatalogByStage = {
    'الصف الأول الابتدائي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
    ],
    'الصف الثاني الابتدائي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
    ],
    'الصف الثالث الابتدائي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
    ],
    'الصف الرابع الابتدائي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
      {'id': 'sci', 'name': 'علوم'},
      {'id': 'social', 'name': 'دراسات اجتماعية'},
    ],
    'الصف الخامس الابتدائي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
      {'id': 'sci', 'name': 'علوم'},
      {'id': 'social', 'name': 'دراسات اجتماعية'},
    ],
    'الصف السادس الابتدائي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
      {'id': 'sci', 'name': 'علوم'},
      {'id': 'social', 'name': 'دراسات اجتماعية'},
    ],
    'الصف الأول الإعدادي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
      {'id': 'sci', 'name': 'علوم'},
      {'id': 'social', 'name': 'دراسات اجتماعية'},
    ],
    'الصف الثاني الإعدادي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
      {'id': 'sci', 'name': 'علوم'},
      {'id': 'social', 'name': 'دراسات اجتماعية'},
    ],
    'الصف الثالث الإعدادي': [
      {'id': 'arabic', 'name': 'لغة عربية'},
      {'id': 'english', 'name': 'لغة إنجليزية'},
      {'id': 'math', 'name': 'رياضيات'},
      {'id': 'sci', 'name': 'علوم'},
      {'id': 'social', 'name': 'دراسات اجتماعية'},
    ],
  };

  String _stageCode(String grade) {
    switch (grade) {
      case 'الصف الأول الابتدائي': return 'p1';
      case 'الصف الثاني الابتدائي': return 'p2';
      case 'الصف الثالث الابتدائي': return 'p3';
      case 'الصف الرابع الابتدائي': return 'p4';
      case 'الصف الخامس الابتدائي': return 'p5';
      case 'الصف السادس الابتدائي': return 'p6';
      case 'الصف الثاني الإعدادي': return 'g2';
      case 'الصف الثالث الإعدادي': return 'g3';
      case 'الصف الأول الإعدادي':
      default:
        return 'g1';
    }
  }

  String _termCode(String term) => term == 'الترم الأول' ? 't1' : 't2';

  // 💎 الاستماع الحي لكل بيانات ولي الأمر وأبنائه
  Future<void> loadParentDashboard() async {
    if (_parentSubscription != null) return;

    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null) {
      emit(ParentState(children: [], errorMessage: 'لم يتم العثور على جلسة مستخدم نشطة ❌'));
      return;
    }

    emit(ParentState(children: state.children, isLoading: true));

    try {
      _parentSubscription = _firestore
          .collection('parents')
          .doc(parentId)
          .snapshots()
          .listen((parentSnap) async {
        if (!parentSnap.exists || parentSnap.data() == null) {
          emit(ParentState(children: [], isLoading: false));
          return;
        }

        final parentData = parentSnap.data() as Map<String, dynamic>;
        List<dynamic> linkedStudents = parentData['linkedStudents'] ?? [];

        // ✅ لو linkedStudents فاضية (حذف آخر طالب) نكنسل فوراً ونعمل emit بقائمة فارغة
        if (linkedStudents.isEmpty) {
          _lastLinkedStudents = [];
          await _childrenSubscription?.cancel();
          _childrenSubscription = null;
          emit(ParentState(children: [], isLoading: false));
          return;
        }

        // ✅ الفحص الذكي: لو القائمة لم تتغير فعلياً لا تعيد بناء الـ stream
        // هذا يمنع الوميض (flicker) الناتج عن الـ Optimistic Update في removeChild
        if (_lastLinkedStudents != null &&
            listEquals(List<String>.from(_lastLinkedStudents!),
                List<String>.from(linkedStudents)) &&
            _childrenSubscription != null) {
          return;
        }
        _lastLinkedStudents = List.from(linkedStudents);

        // ✅ رفع الجيل قبل إنشاء أي subscription جديد
        _fetchGeneration++;
        final int currentGeneration = _fetchGeneration;

        // ✅ كنسلة فورية متزامنة للـ stream القديم قبل بناء الجديد
        await _childrenSubscription?.cancel();
        _childrenSubscription = null;

        _childrenSubscription = _firestore
            .collection('students')
            .where(FieldPath.documentId, whereIn: linkedStudents)
            .snapshots()
            .listen((studentsSnap) async {
          try {
            // ✅ لو جاء جيل جديد (trigger تاني) بعد ما بدأنا الحساب ده، نتجاهله
            if (currentGeneration != _fetchGeneration) return;

            List<Map<String, dynamic>> fetchedChildren = [];

            final QuerySnapshot teachersSnap =
                await _firestore.collection('teachers').get();

            // ✅ فحص الجيل مرة ثانية بعد الـ await (قد يكون تغيّر أثناء انتظار Firestore)
            if (currentGeneration != _fetchGeneration) return;

            for (var studentDoc in studentsSnap.docs) {
              final studentData = studentDoc.data() as Map<String, dynamic>;
              final String studentId = studentDoc.id;
              final String grade = studentData['stage'] ?? 'الصف الأول الإعدادي';
              final String term = studentData['term'] ?? 'الترم الثاني';
              final List<dynamic> unlockedPackages =
                  studentData['unlockedPackages'] ?? [];

              final String stageCode = _stageCode(grade);
              final String termCode = _termCode(term);

              final Map<String, Map<String, dynamic>> liveContentBySubject = {};
              for (var teacherDoc in teachersSnap.docs) {
                final teacherData = teacherDoc.data() as Map<String, dynamic>;
                if (teacherData['isActive'] == false) continue;

                final List<dynamic> assignedCourses =
                    teacherData['assignedCourses'] ?? [];
                for (var courseRaw in assignedCourses) {
                  final course = courseRaw as Map<String, dynamic>;
                  if (course['stage'] == grade && course['term'] == term) {
                    final String sid = course['subject'] ?? '';
                    if (sid.isNotEmpty &&
                        !liveContentBySubject.containsKey(sid)) {
                      liveContentBySubject[sid] = {
                        'teacherId': teacherDoc.id,
                        'subjectTitle': null,
                      };
                    }
                  }
                }
              }

              final List<Map<String, String>> catalog =
                  _subjectsCatalogByStage[grade] ?? [];
              final List<Map<String, dynamic>> subjects =
                  catalog.map((subject) {
                final String subjectId = subject['id']!;
                final String packageId =
                    '${subjectId}_${stageCode}_${termCode}';
                final live = liveContentBySubject[subjectId];

                return <String, dynamic>{
                  'subjectId': subjectId,
                  'subjectName': live?['subjectTitle'] ?? subject['name'],
                  'packageId': packageId,
                  'isAvailable': live != null,
                  'teacherId': live?['teacherId'],
                  'isUnlocked': unlockedPackages.contains(packageId),
                };
              }).toList();

              final bool hasAvailableSubjects =
                  subjects.any((s) => s['isAvailable'] == true);
              final bool isPaid = !hasAvailableSubjects ||
                  subjects
                      .where((s) => s['isAvailable'] == true)
                      .every((s) => s['isUnlocked'] == true);

              QuerySnapshot progressSnap = await _firestore
                  .collection('student_progress')
                  .where('studentId', isEqualTo: studentId)
                  .get();

              // ✅ فحص الجيل بعد كل await ثقيل
              if (currentGeneration != _fetchGeneration) return;

              double totalPerformance = 0.0;
              if (progressSnap.docs.isNotEmpty) {
                double totalScore = 0.0;
                for (var doc in progressSnap.docs) {
                  final pData = doc.data() as Map<String, dynamic>;
                  final double quizScore =
                      (pData['quizScore'] ?? 0).toDouble();
                  final bool isWatched = pData['isVideoWatched'] ?? false;
                  double lessonProgress =
                      (isWatched ? 0.4 : 0) + ((quizScore / 10) * 0.6);
                  totalScore += lessonProgress;
                }
                totalPerformance = totalScore / progressSnap.docs.length;
              }

              fetchedChildren.add({
                'id': studentId,
                'name': studentData['name'] ?? 'طالب فاهم',
                'stage': grade,
                'term': term,
                'overallPerformance':
                    totalPerformance > 0 ? totalPerformance : 0.0,
                'isPaid': isPaid,
                'unlockedPackages': unlockedPackages,
                'subjects': subjects,
              });
            }

            // ✅ فحص نهائي للجيل قبل الـ emit
            if (currentGeneration != _fetchGeneration) return;
            emit(ParentState(children: fetchedChildren, isLoading: false));
          } catch (e) {
            print('=== [ParentCubit Error 🚨] فشل تحديث بيانات الأبناء: $e ===');
            if (currentGeneration != _fetchGeneration) return;
            emit(ParentState(
              children: state.children,
              isLoading: false,
              errorMessage: 'حدث خطأ أثناء تحديث بيانات الأبناء: $e',
            ));
          }
        }, onError: (e) {
          emit(ParentState(
            children: state.children,
            isLoading: false,
            errorMessage: 'خطأ في بث الأبناء: $e',
          ));
        });
      }, onError: (e) {
        emit(ParentState(
          children: state.children,
          isLoading: false,
          errorMessage: 'خطأ في بث ولي الأمر: $e',
        ));
      });
    } catch (e) {
      emit(ParentState(
        children: state.children,
        isLoading: false,
        errorMessage: 'حدث خطأ غير متوقع: $e',
      ));
    }
  }

  // دالة ربط ابن جديد
  Future<void> linkChild(String code) async {
    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null || code.trim().isEmpty) return;

    try {
      QuerySnapshot studentQuery = await _firestore
          .collection('students')
          .where('linkCode', isEqualTo: code.trim())
          .get();

      if (studentQuery.docs.isEmpty) {
        throw 'كود الربط الذي أدخلته غير صحيح أو غير مسجل في المنظومة ❌';
      }

      final studentDoc = studentQuery.docs.first;
      final String studentId = studentDoc.id;

      WriteBatch batch = _firestore.batch();
      batch.update(_firestore.collection('students').doc(studentId), {
        'parentIds': FieldValue.arrayUnion([parentId]),
      });
      batch.update(_firestore.collection('parents').doc(parentId), {
        'linkedStudents': FieldValue.arrayUnion([studentId]),
      });

      await batch.commit();
    } catch (e) {
      emit(ParentState(children: state.children, errorMessage: e.toString()));
      rethrow;
    }
  }

  // 💎 دفع الاشتراك لمادة محددة
  Future<String?> paySubscription({
    required String childId,
    required String subjectId,
    required String teacherId,
    required double amount,
  }) async {
    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null) return 'لم يتم العثور على جلسة مستخدم نشطة';

    try {
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(childId).get();
      if (!studentDoc.exists) return 'الطالب غير موجود';

      final studentData = studentDoc.data() as Map<String, dynamic>;
      final String grade = studentData['stage'] ?? 'الصف الأول الإعدادي';
      final String term = studentData['term'] ?? 'الترم الثاني';
      final List<dynamic> unlockedPackages =
          studentData['unlockedPackages'] ?? [];

      final String packageId =
          '${subjectId}_${_stageCode(grade)}_${_termCode(term)}';

      if (unlockedPackages.contains(packageId)) return null;

      final double platformShare = amount / 3;
      final double teacherShare = amount - platformShare;

      WriteBatch batch = _firestore.batch();

      batch.update(_firestore.collection('students').doc(childId), {
        'unlockedPackages': FieldValue.arrayUnion([packageId]),
      });

      final DocumentReference transactionRef =
          _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'type': 'subscription',
        'parentId': parentId,
        'studentId': childId,
        'teacherId': teacherId,
        'subjectId': subjectId,
        'packageId': packageId,
        'packageName': '$grade - $term',
        'totalAmountPaid': amount,
        'platformProfit': platformShare,
        'teachersProfit': teacherShare,
        'currency': 'EGP',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('teachers').doc(teacherId), {
        'availableBalance': FieldValue.increment(teacherShare),
        'totalStudents': FieldValue.increment(1),
      });

      await batch.commit();
      return null;
    } catch (e) {
      emit(ParentState(
          children: state.children,
          errorMessage: 'فشلت عملية السداد الرقمي: $e'));
      return 'فشلت عملية السداد الرقمي: $e';
    }
  }

  // دالة إلغاء ربط حساب الابن سحابياً بالكامل
  Future<void> removeChild(String childId) async {
    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null) return;

    try {
      // ✅ 1) Optimistic UI: احذف الطالب من الشاشة فوراً بدون انتظار Firestore
      final updatedChildren =
          state.children.where((child) => child['id'] != childId).toList();
      emit(ParentState(children: updatedChildren, isLoading: false));

      // ✅ 2) حدّث _lastLinkedStudents يدوياً قبل الـ commit
      // ده بيخلي الـ _parentSubscription لما يرد على التغيير السحابي
      // يشوف إن القائمة "ما اتغيرتش من وجهة نظره" فيتجاهل إعادة بناء الـ stream
      // وبكده نمنع الطالب من الظهور تاني لثانية واحدة (الوميض)
      _lastLinkedStudents =
          (_lastLinkedStudents ?? []).where((id) => id != childId).toList();

      // ✅ 3) لو الطالب المحذوف كان الأخير، نكنسل الـ stream الحالي فوراً
      if (_lastLinkedStudents!.isEmpty) {
        await _childrenSubscription?.cancel();
        _childrenSubscription = null;
      }

      WriteBatch batch = _firestore.batch();
      batch.update(_firestore.collection('students').doc(childId), {
        'parentIds': FieldValue.arrayRemove([parentId]),
      });
      batch.update(_firestore.collection('parents').doc(parentId), {
        'linkedStudents': FieldValue.arrayRemove([childId]),
      });

      await batch.commit();
    } catch (e) {
      // ✅ لو فشل الـ commit، نرجع للحالة القديمة
      emit(ParentState(
          children: state.children,
          errorMessage: 'فشل إلغاء ربط الحساب سحابياً: $e'));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _parentSubscription?.cancel();
    _childrenSubscription?.cancel();
    return super.close();
  }
}