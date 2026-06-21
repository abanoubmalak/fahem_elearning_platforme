// lib/features/home/presentation/cubit/student_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/subject_provider.dart';
import '../../data/models/subject_model.dart';

abstract class StudentState {}
class StudentInitial extends StudentState {}
class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<SubjectModel> subjects;
  final String name;
  final String email;
  final String grade;
  final String term;
  final String linkingCode;
  final bool hasSubscription;
  final double overallProgress; 
  final List<dynamic> unlockedPackages;

  StudentLoaded({
    required this.subjects, 
    required this.name, 
    required this.email,
    required this.grade, 
    required this.term, 
    required this.linkingCode,
    required this.hasSubscription,
    required this.overallProgress,
    required this.unlockedPackages,
  });
}

class StudentUpdateSuccess extends StudentLoaded {
  StudentUpdateSuccess({
    required super.subjects,
    required super.name,
    required super.email,
    required super.grade,
    required super.term,
    required super.linkingCode,
    required super.hasSubscription,
    required super.overallProgress,
    required super.unlockedPackages,
  });
}

class StudentLoggedOut extends StudentState {}
class StudentError extends StudentState {
  final String message;
  StudentError(this.message);
}

class StudentCubit extends Cubit<StudentState> {
  StudentCubit() : super(StudentInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 💎 خريطة تحويل: الـ id الداخلي في SubjectProvider قد يختلف عن
  // الـ prefix المستخدم فعلياً في فايربيز (unlockedPackages / subjects_content).
  // مثال: مادة اللغة العربية id داخلي = 'ar' لكن المخزن في فايربيز 'arabic'.
  // أي مادة مش موجودة هنا، هيتم استخدام sub.id كما هو بدون تغيير.
  static const Map<String, String> _firestoreSubjectIdMap = {
    'ar': 'arabic',
  };

  // 👈 دالة موحّدة لحساب الـ id المستخدم فعلياً في فايربيز لأي مادة
  String _firestoreSubjectId(String localId) {
    return _firestoreSubjectIdMap[localId] ?? localId;
  }

  void safeEmit(StudentState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> loadStudentDashboard() async {
    if (state is StudentLoading || (state is StudentLoaded && (state as StudentLoaded).subjects.isNotEmpty)) {
      return;
    }

    safeEmit(StudentLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        safeEmit(StudentError('لم يتم العثور على جلسة مستخدم نشطة ❌'));
        return;
      }

      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(currentUser.uid).get();

      if (!studentDoc.exists || studentDoc.data() == null) {
        await _firestore.collection('students').doc(currentUser.uid).set({
          'name': 'طالب فاهم (تجريبي)',
          'email': currentUser.email ?? 'student@fahem.com',
          'stage': 'الصف الأول الإعدادي',
          'term': 'الترم الثاني',
          'isActive': true,
          'linkCode': 'FAHEM-${currentUser.uid.substring(0, 5).toUpperCase()}',
          'unlockedPackages': ['sci_g1_t2'],
        }, SetOptions(merge: true));

        studentDoc = await _firestore.collection('students').doc(currentUser.uid).get();
      }

      Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;

      String liveName = data['name'] ?? 'طالب فاهم';
      String liveEmail = data['email'] ?? currentUser.email ?? '';
      String liveGrade = data['stage'] ?? 'الصف الأول الإعدادي';
      String liveTerm = data['term'] ?? 'الترم الثاني';
      String liveCode = data['linkCode'] ?? 'FAHEM-${currentUser.uid.substring(0, 5).toUpperCase()}';
      
      List<dynamic> unlockedPackages = data['unlockedPackages'] ?? [];
      bool liveSubscription = unlockedPackages.isNotEmpty;

      // 1. جلب سجل تقدم الطالب بالكامل
      QuerySnapshot progressSnap = await _firestore.collection('student_progress')
          .where('studentId', isEqualTo: currentUser.uid).get();
      
      double totalScore = 0.0;
      // خريطة لحساب مجمّع التقدم لكل مادة بشكل مستقل عن الأخرى
      Map<String, double> subjectProgressMap = {};
      Map<String, int> subjectCountMap = {};

      if (progressSnap.docs.isNotEmpty) {
        for (var doc in progressSnap.docs) {
          final pData = doc.data() as Map<String, dynamic>;
          final String subId = pData['subjectId'] ?? 'sci';
          final double quizScore = (pData['quizScore'] ?? 0).toDouble();
          final bool isWatched = pData['isVideoWatched'] ?? false;
          
          double lessonProgress = (isWatched ? 0.4 : 0) + ((quizScore / 10) * 0.6);
          totalScore += lessonProgress;

          // تجميع القيم حسب المادة لتحديث الـ Progress Bar الخاص بكل مادة
          subjectProgressMap[subId] = (subjectProgressMap[subId] ?? 0.0) + lessonProgress;
          subjectCountMap[subId] = (subjectCountMap[subId] ?? 0) + 1;
        }
        totalScore = totalScore / progressSnap.docs.length; 
      }

      // 2. ربط وحقن التقدم الحقيقي داخل كروت المواد
      List<SubjectModel> rawSubjects = SubjectProvider.getSubjectsByGrade(liveGrade);
      List<SubjectModel> processedSubjects = rawSubjects.map((sub) {
        String stageCode = 'g1';
        if (liveGrade == 'الصف الثاني الإعدادي') stageCode = 'g2';
        if (liveGrade == 'الصف الثالث الإعدادي') stageCode = 'g3';
        String termCode = liveTerm == 'الترم الأول' ? 't1' : 't2';

        // 💎 استخدام الـ id المطابق لما هو مخزّن فعلياً في فايربيز
        String firestoreId = _firestoreSubjectId(sub.id);
        String packageId = '${firestoreId}_${stageCode}_${termCode}';

        // حساب التقدم الفردي للمادة الحالية بناءً على الداتابيز
        // (الجلب من student_progress يتم بالـ id المحلي كما هو محفوظ من شاشات الدرس/الاختبار)
        double calculatedSubjectProgress = 0.0;
        if (subjectCountMap.containsKey(sub.id) && subjectCountMap[sub.id]! > 0) {
          calculatedSubjectProgress = subjectProgressMap[sub.id]! / subjectCountMap[sub.id]!;
        }

        return sub.copyWith(
          isUnlocked: unlockedPackages.contains(packageId),
          packageId: packageId,
          progress: calculatedSubjectProgress > 0 ? calculatedSubjectProgress : 0.0, // حقن القيمة الحية
        );
      }).toList();

      safeEmit(StudentLoaded(
        subjects: processedSubjects,
        name: liveName,
        email: liveEmail,
        grade: liveGrade,
        term: liveTerm,
        linkingCode: liveCode,
        hasSubscription: liveSubscription,
        overallProgress: totalScore,
        unlockedPackages: unlockedPackages,
      ));
      
    } catch (e) {
      safeEmit(StudentError('حدث خطأ أثناء مزامنة بياناتك الأكاديمية: $e'));
    }
  }

  Future<void> updateStudentProfile({
    required String newName, 
    required String newGrade, 
    required String newTerm,
    String? oldPassword, 
    String? newPassword,
  }) async {
    if (state is! StudentLoaded) return;
    final currentState = state as StudentLoaded;
    safeEmit(StudentLoading());

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      if (oldPassword != null && newPassword != null && oldPassword.isNotEmpty && newPassword.isNotEmpty) {
        try {
          AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: oldPassword);
          await currentUser.reauthenticateWithCredential(credential);
          await currentUser.updatePassword(newPassword);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            safeEmit(StudentError('كلمة المرور الحالية التي أدخلتها غير صحيحة ❌'));
          } else {
            safeEmit(StudentError('حدث خطأ أثناء تحديث كلمة المرور، حاول مجدداً.'));
          }
          safeEmit(currentState); 
          return; 
        }
      }

      await _firestore.collection('students').doc(currentUser.uid).update({
        'name': newName.trim(),
        'stage': newGrade,
        'term': newTerm,
      });

      List<SubjectModel> rawSubjects = SubjectProvider.getSubjectsByGrade(newGrade);
      List<SubjectModel> processedSubjects = rawSubjects.map((sub) {
        String stageCode = 'g1';
        if (newGrade == 'الصف الثاني الإعدادي') stageCode = 'g2';
        if (newGrade == 'الصف الثالث الإعدادي') stageCode = 'g3';
        String termCode = newTerm == 'الترم الأول' ? 't1' : 't2';

        // 💎 نفس خريطة التحويل هنا أيضاً لضمان التطابق بعد تعديل بيانات الطالب
        String firestoreId = _firestoreSubjectId(sub.id);
        String packageId = '${firestoreId}_${stageCode}_${termCode}';

        return sub.copyWith(
          isUnlocked: currentState.unlockedPackages.contains(packageId),
          packageId: packageId,
          progress: sub.progress, 
        );
      }).toList();

      safeEmit(StudentUpdateSuccess(
        subjects: processedSubjects,
        name: newName.trim(),
        email: currentState.email,
        grade: newGrade,
        term: newTerm,
        linkingCode: currentState.linkingCode,
        hasSubscription: currentState.hasSubscription,
        overallProgress: currentState.overallProgress,
        unlockedPackages: currentState.unlockedPackages,
      ));
      
    } catch (e) {
      safeEmit(StudentError('فشل في حفظ التعديلات، يرجى المحاولة لاحقاً.'));
      safeEmit(currentState);
    }
  }
  
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      safeEmit(StudentLoggedOut());
    } catch (e) {
      safeEmit(StudentError('حدث خطأ أثناء تسجيل الخروج.'));
    }
  }
}