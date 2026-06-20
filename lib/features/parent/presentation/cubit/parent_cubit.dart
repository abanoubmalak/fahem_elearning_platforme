// lib/features/parent/presentation/cubit/parent_cubit.dart
import 'dart:async'; // 👈 استيراد مكتبة الـ Async للتحكم في تدفق البث اللحظي
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
    loadParentDashboard(); // تشغيل البث الحي المتزامن فور ولادة الكوبيت
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // معرفات كائنات الاستماع لحمايتها من التكرار وتسريب الذاكرة (Memory Leaks)
  StreamSubscription? _parentSubscription;
  StreamSubscription? _childrenSubscription;

  // 💎 تحويل الدالة لتصبح مستمعاً حياً (Real-time Stream Listener) لجميع التغييرات سحابياً
  Future<void> loadParentDashboard() async {
    // حماية هندسية: إذا كان البث نشطاً بالفعل لا تقم بإنشاء مستمع جديد تفادياً لتكرار البيانات
    if (_parentSubscription != null) return;

    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null) {
      emit(ParentState(children: [], errorMessage: 'لم يتم العثور على جلسة مستخدم نشطة ❌'));
      return;
    }

    emit(ParentState(children: state.children, isLoading: true));

    try {
      // 1. الاستماع اللحظي الحركي لحساب ولي الأمر عند إضافة أو إلغاء ربط الأبناء
      _parentSubscription = _firestore
          .collection('parents')
          .doc(parentId)
          .snapshots() // 👈 استخدام snapshots بدلاً من get للبث الحي المستمر
          .listen((parentSnap) async {
        
        if (!parentSnap.exists || parentSnap.data() == null) {
          emit(ParentState(children: [], isLoading: false));
          return;
        }

        final parentData = parentSnap.data() as Map<String, dynamic>;
        List<dynamic> linkedStudents = parentData['linkedStudents'] ?? [];

        if (linkedStudents.isEmpty) {
          emit(ParentState(children: [], isLoading: false));
          return;
        }

        // إلغاء الاستماع القديم للأبناء لإعادة بناء نطاق البحث المحدث سحابياً بأمان
        await _childrenSubscription?.cancel();

        // 2. 💎 الاستماع اللحظي الحقيقي لجميع مستندات الطلاب المربوطين معاً دفعة واحدة 💎
        _childrenSubscription = _firestore
            .collection('students')
            .where(FieldPath.documentId, whereIn: linkedStudents)
            .snapshots() // 👈 أي حذف للباقات في الفايربيز كونسول سيُطلق هذا المستمع أوتوماتيكياً فوراً!
            .listen((studentsSnap) async {
          
          List<Map<String, dynamic>> fetchedChildren = [];

          for (var studentDoc in studentsSnap.docs) {
            final studentData = studentDoc.data();
            final String studentId = studentDoc.id;
            final String grade = studentData['stage'] ?? 'الصف الأول الإعدادي';
            final String term = studentData['term'] ?? 'الترم الثاني';
            List<dynamic> unlockedPackages = studentData['unlockedPackages'] ?? [];

            // تحديد باقة الترم والمرحلة المعتمدة حياً
            String stageCode = 'g1';
            if (grade == 'الصف الثاني الإعدادي') stageCode = 'g2';
            if (grade == 'الصف الثالث الإعدادي') stageCode = 'g3';
            String termCode = term == 'الترم الأول' ? 't1' : 't2';
            String expectedPackage = 'sci_${stageCode}_${termCode}';

            bool isPaid = unlockedPackages.contains(expectedPackage);

            // حساب معدل الأداء الدراسي التراكمي
            QuerySnapshot progressSnap = await _firestore
                .collection('student_progress')
                .where('studentId', isEqualTo: studentId)
                .get();

            double totalPerformance = 0.0;
            if (progressSnap.docs.isNotEmpty) {
              double totalScore = 0.0;
              for (var doc in progressSnap.docs) {
                final pData = doc.data() as Map<String, dynamic>;
                final double quizScore = (pData['quizScore'] ?? 0).toDouble();
                final bool isWatched = pData['isVideoWatched'] ?? false;
                
                double lessonProgress = (isWatched ? 0.4 : 0) + ((quizScore / 10) * 0.6);
                totalScore += lessonProgress;
              }
              totalPerformance = totalScore / progressSnap.docs.length;
            }

            fetchedChildren.add({
              'id': studentId,
              'name': studentData['name'] ?? 'طالب فاهم',
              'stage': grade,
              'term': term,
              'overallPerformance': totalPerformance > 0 ? totalPerformance : 0.0,
              'isPaid': isPaid,
            });
          }

          // بث مصفوفة الأبناء الحية لتحديث شاشات (الرئيسية، الدفع، التقرير) لحظياً!
          emit(ParentState(children: fetchedChildren, isLoading: false));
        }, onError: (e) {
          emit(ParentState(children: state.children, isLoading: false, errorMessage: 'خطأ في بث الأبناء: $e'));
        });

      }, onError: (e) {
        emit(ParentState(children: state.children, isLoading: false, errorMessage: 'خطأ في بث ولي الأمر: $e'));
      });

    } catch (e) {
      emit(ParentState(children: state.children, isLoading: false, errorMessage: 'حدث خطأ غير متوقع: $e'));
    }
  }

  // دالة ربط ابن جديد باستخدام كود الربط العشوائي سحابياً
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
      // 💡 ملاحظة احترافية: لا نحتاج لاستدعاء loadParentDashboard يدوياً هنا، لأن البث الحي سيلتقط الإضافة تلقائياً!
    } catch (e) {
      emit(ParentState(children: state.children, errorMessage: e.toString()));
      rethrow;
    }
  }

  // دالة دفع الاشتراك وتحديث الحالة حياً وتوثيق الفاتورة
  Future<void> paySubscription(String childId) async {
    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null) return;

    try {
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(childId).get();
      if (!studentDoc.exists) return;

      final studentData = studentDoc.data() as Map<String, dynamic>;
      final String grade = studentData['stage'] ?? 'الصف الأول الإعدادي';
      final String term = studentData['term'] ?? 'الترم الثاني';

      String stageCode = 'g1';
      if (grade == 'الصف الثاني الإعدادي') stageCode = 'g2';
      if (grade == 'الصف الثالث الإعدادي') stageCode = 'g3';
      String termCode = term == 'الترم الأول' ? 't1' : 't2';
      String packageId = 'sci_${stageCode}_${termCode}';

      WriteBatch batch = _firestore.batch();
      batch.update(_firestore.collection('students').doc(childId), {
        'unlockedPackages': FieldValue.arrayUnion([packageId]),
      });

      final DocumentReference transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'type': 'subscription',
        'parentId': parentId,
        'studentId': childId,
        'packageId': packageId,
        'packageName': '$grade - $term',
        'totalAmountPaid': 150.0,
        'platformProfit': 50.0,
        'teachersProfit': 100.0,
        'currency': 'EGP',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      emit(ParentState(children: state.children, errorMessage: 'فشلت عملية السداد الرقمي: $e'));
    }
  }

  // دالة إلغاء ربط حساب الابن سحابياً بالكامل
  Future<void> removeChild(String childId) async {
    final String? parentId = _auth.currentUser?.uid;
    if (parentId == null) return;

    try {
      WriteBatch batch = _firestore.batch();
      batch.update(_firestore.collection('students').doc(childId), {
        'parentIds': FieldValue.arrayRemove([parentId]),
      });
      batch.update(_firestore.collection('parents').doc(parentId), {
        'linkedStudents': FieldValue.arrayRemove([childId]),
      });

      await batch.commit();
    } catch (e) {
      emit(ParentState(children: state.children, errorMessage: 'فشل إلغاء ربط الحساب سحابياً: $e'));
    }
  }

  // تنظيف وإغلاق اشتراكات البث عند تدمير الكوبيت لحماية استهلاك الذاكرة والمعالج
  @override
  Future<void> close() {
    _parentSubscription?.cancel();
    _childrenSubscription?.cancel();
    return super.close();
  }
}