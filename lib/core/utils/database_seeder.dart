// lib/core/utils/database_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedCompleteFahemDatabase({BuildContext? context}) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // ثابتات للتجربة
      const String studentId = 'STUDENT_UID_1';
      const String parentId = 'PARENT_UID_1';
      const String teacherId = 'TEACHER_UID_1';
      const String adminId = 'ADMIN_UID_1';

      const String subjectDocId = 'sci_g1_t2';
      const String unitId = 'UNIT_ID_1';
      const String lessonId = 'LESSON_ID_1';
      const String questionId = 'QUESTION_ID_1';

      // ---------------------------
      // 1) users
      // ---------------------------
      batch.set(
        _firestore.collection('users').doc(studentId),
        {
          'email': 'student@fahem.com',
          'role': 'student',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection('users').doc(parentId),
        {
          'email': 'parent@fahem.com',
          'role': 'parent',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection('users').doc(teacherId),
        {
          'email': 'abanoub@fahem.com',
          'role': 'teacher',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection('users').doc(adminId),
        {
          'email': 'admin@fahem.com',
          'role': 'admin',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 2) parents
      // ---------------------------
      batch.set(
        _firestore.collection('parents').doc(parentId),
        {
          'name': 'أحمد محمود',
          'email': 'parent@fahem.com',
          'isActive': true,
          'linkedStudents': [studentId],
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 3) students
      // ---------------------------
      batch.set(
        _firestore.collection('students').doc(studentId),
        {
          'name': 'يوسف أحمد',
          'email': 'youssef@fahem.com',
          'phone': '01012345678',
          'stage': 'الصف الأول الإعدادي',
          'term': 'الترم الثاني',
          'linkCode': 'FAHEM-9876',
          'parentIds': [parentId],
          'isActive': true,
          'unlockedPackages': [
            'sci_g1_t1',
            'sci_g1_t2',
          ],
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 4) teachers
      // ---------------------------
      batch.set(
        _firestore.collection('teachers').doc(teacherId),
        {
          'name': 'أبانوب ملاك',
          'email': 'abanoub@fahem.com',
          'phone': '01234567890',
          'specialty': 'رياضيات',
          'isActive': true,
          'availableBalance': 2500.0,
          'pendingBalance': 0.0,
          'totalStudents': 140,
          'averageScore': 85.5,
          'assignedCourses': [
            {
              'subject': 'sci',
              'stage': 'الصف الأول الإعدادي',
              'term': 'الترم الثاني',
            }
          ],
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 5) subjects_content
      // ---------------------------
      final DocumentReference<Map<String, dynamic>> subjectRef =
          _firestore.collection('subjects_content').doc(subjectDocId);

      batch.set(
        subjectRef,
        {
          'subjectTitle': 'العلوم',
          'subjectId': 'sci',
          'stage': 'الصف الأول الإعدادي',
          'term': 'الترم الثاني',
          'teacherId': teacherId,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // unit
      final DocumentReference<Map<String, dynamic>> unitRef =
          subjectRef.collection('units').doc(unitId);

      batch.set(
        unitRef,
        {
          'title': 'الوحدة الأولى: المادة وتركيبها',
          'order': 1,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // lesson
      final DocumentReference<Map<String, dynamic>> lessonRef =
          unitRef.collection('lessons').doc(lessonId);

      batch.set(
        lessonRef,
        {
          'title': 'الدرس الأول: خواص المادة',
          'videoUrl':
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          'summary': 'يتم تعريف المادة بأنها كل ما له كتلة ويشغل حيزاً من الفراغ.',
          'order': 1,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // lesson questions as subcollection
      final DocumentReference<Map<String, dynamic>> questionRef =
          lessonRef.collection('questions').doc(questionId);

      batch.set(
        questionRef,
        {
          'question': 'ما هي وحدة قياس الكثافة؟',
          'options': ['جم', 'سم٣', 'جم/سم٣', 'كجم'],
          'correctIndex': 2,
          'order': 1,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 6) student_progress
      // ---------------------------
      batch.set(
        _firestore.collection('student_progress').doc('${studentId}_$lessonId'),
        {
          'studentId': studentId,
          'lessonId': lessonId,
          'subjectId': 'sci',
          'unitId': unitId,
          'isVideoWatched': true,
          'quizScore': 8,
          'isCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 7) teacher_questions
      // ---------------------------
      final DocumentReference<Map<String, dynamic>> teacherQuestionRef =
          _firestore.collection('teacher_questions').doc();

      batch.set(
        teacherQuestionRef,
        {
          'teacherId': teacherId,
          'studentId': studentId,
          'studentName': 'يوسف أحمد',
          'question': 'يا مستر مش فاهم قانون الكثافة؟',
          'reply': 'الكثافة تساوي الكتلة على الحجم يا بطل.',
          'isReplied': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 8) transactions
      // ---------------------------
      final DocumentReference<Map<String, dynamic>> transactionRef =
          _firestore.collection('transactions').doc();

      batch.set(
        transactionRef,
        {
          'type': 'subscription',
          'parentId': parentId,
          'studentId': studentId,
          'packageId': 'sci_g1_t2',
          'packageName': 'الصف الأول الإعدادي - الترم الثاني',
          'totalAmountPaid': 150.0,
          'platformProfit': 50.0,
          'teachersProfit': 100.0,
          'currency': 'EGP',
          'status': 'completed',
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ---------------------------
      // 9) withdrawal_requests
      // ---------------------------
      final DocumentReference<Map<String, dynamic>> withdrawalRef =
          _firestore.collection('withdrawal_requests').doc();

      batch.set(
        withdrawalRef,
        {
          'teacherId': teacherId,
          'teacherName': 'أبانوب ملاك',
          'amount': 500.0,
          'method': 'vodafone_cash',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // تنفيذ
      await batch.commit();

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إنشاء قاعدة البيانات بنجاح 🚀',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      debugPrint('Seeder error: $e');

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء بناء القاعدة: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}