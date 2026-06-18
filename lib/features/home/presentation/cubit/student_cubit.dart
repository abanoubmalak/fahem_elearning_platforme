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

  StudentLoaded({
    required this.subjects, 
    required this.name, 
    required this.email,
    required this.grade, 
    required this.term, 
    required this.linkingCode,
    required this.hasSubscription,
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

  Future<void> loadStudentDashboard() async {
    if (state is StudentLoading || (state is StudentLoaded && (state as StudentLoaded).subjects.isNotEmpty)) {
      return;
    }

    emit(StudentLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(StudentError('لم يتم العثور على جلسة مستخدم نشطة ❌'));
        return;
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        String liveName = data['name'] ?? 'طالب فاهم';
        String liveEmail = data['email'] ?? currentUser.email ?? '';
        String liveGrade = data['grade'] ?? 'غير محدد';
        String liveTerm = data['term'] ?? 'الترم الأول';
        bool liveSubscription = data['has_active_subscription'] ?? false;
        String liveCode = data['linking_code'] ?? 'FAHEM-${currentUser.uid.substring(0, 5).toUpperCase()}';

        List<SubjectModel> filteredSubjects = SubjectProvider.getSubjectsByGrade(liveGrade);

        emit(StudentLoaded(
          subjects: filteredSubjects,
          name: liveName,
          email: liveEmail,
          grade: liveGrade,
          term: liveTerm,
          linkingCode: liveCode,
          hasSubscription: liveSubscription,
        ));
      } else {
        emit(StudentError('مستند بيانات الطالب غير موجود ⚠️'));
      }
    } catch (e) {
      emit(StudentError('حدث خطأ أثناء مزامنة بياناتك الأكاديمية.'));
    }
  }

  // دالة التحديث الشاملة (بيانات دراسية + أمان)
  // دالة التحديث الشاملة (بيانات دراسية + أمان)
  Future<void> updateStudentProfile({
    required String newName, 
    required String newGrade, 
    required String newTerm,
    String? oldPassword, 
    String? newPassword,
  }) async {
    // 👈 1. أخذ نسخة احتياطية من الحالة الحالية لإرجاعها عند حدوث خطأ لمنع تجمد الشاشة
    if (state is! StudentLoaded) return;
    final currentState = state as StudentLoaded;

    emit(StudentLoading()); // تشغيل اللودر

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // 2. فحص وتحديث كلمة المرور
      if (oldPassword != null && newPassword != null && oldPassword.isNotEmpty && newPassword.isNotEmpty) {
        print('=== [StudentCubit 🔐] جاري فحص كلمة المرور القديمة ===');
        try {
          AuthCredential credential = EmailAuthProvider.credential(
            email: currentUser.email!,
            password: oldPassword,
          );
          await currentUser.reauthenticateWithCredential(credential);
          await currentUser.updatePassword(newPassword);
          print('=== [StudentCubit 🔐] تم تحديث كلمة المرور بنجاح! ===');
        } on FirebaseAuthException catch (e) {
          // 👈 بث حالة الخطأ لعرضها، ثم استرجاع واجهة المستخدم فوراً
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            emit(StudentError('كلمة المرور الحالية التي أدخلتها غير صحيحة ❌'));
          } else {
            emit(StudentError('حدث خطأ أثناء تحديث كلمة المرور، حاول مجدداً.'));
          }
          emit(currentState); // إرجاع الواجهة بدون فقدان البيانات المكتوبة
          return; // إيقاف التنفيذ وعدم حفظ التعديلات الأخرى
        }
      }

      // 3. تحديث البيانات الدراسية في الفايرستور سحابياً
      await _firestore.collection('users').doc(currentUser.uid).update({
        'name': newName.trim(),
        'grade': newGrade,
        'term': newTerm,
      });

      // 4. التحديث المحلي الفوري
      List<SubjectModel> updatedSubjects = SubjectProvider.getSubjectsByGrade(newGrade);

      emit(StudentUpdateSuccess(
        subjects: updatedSubjects,
        name: newName.trim(),
        email: currentState.email,
        grade: newGrade,
        term: newTerm,
        linkingCode: currentState.linkingCode,
        hasSubscription: currentState.hasSubscription,
      ));
      
    } catch (e) {
      emit(StudentError('فشل في حفظ التعديلات، يرجى المحاولة لاحقاً.'));
      emit(currentState); // إرجاع الواجهة عند الخطأ
    }
  }
  
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      emit(StudentLoggedOut());
    } catch (e) {
      emit(StudentError('حدث خطأ أثناء تسجيل الخروج.'));
    }
  }
}