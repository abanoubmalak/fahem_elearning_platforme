import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/email_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();
  final EmailService _emailService = EmailService();

  AuthCubit() : super(AuthInitial());

  String? tempName;
  String? tempEmail;
  String? tempPassword;
  String? tempForgotEmail;
  String? tempForgotOtp;

  void saveBasicInfo({required String name, required String email, required String password}) {
    tempName = name;
    tempEmail = email;
    tempPassword = password;
  }

  Future<void> completeRegistration({required String role, String? grade, String? term}) async {
    emit(AuthLoading());
    try {
      if (tempEmail == null || tempName == null || tempPassword == null) {
        emit(AuthFailure('بيانات الحساب الأساسية مفقودة، يرجى إعادة المحاولة ⚠️'));
        return;
      }

      final String normalizedEmail = tempEmail!.trim().toLowerCase();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      String generatedOtp = (1000 + Random().nextInt(9000)).toString();

      User? user;

      try {
        user = await _authService.signUpUser(
          name: tempName!,
          email: tempEmail!,
          password: tempPassword!,
          role: role,
        ).timeout(const Duration(seconds: 8));
      } on FirebaseAuthException catch (authError) {
        if (authError.code != 'email-already-in-use') rethrow;

        final existingDocs = await firestore
            .collection('users')
            .where('email', isEqualTo: normalizedEmail)
            .limit(1)
            .get();

        if (existingDocs.docs.isEmpty) {
          emit(AuthFailure('هذا البريد الإلكتروني مستخدم بالفعل، يمكنك تسجيل الدخول أو استخدام "نسيت كلمة المرور" 👥'));
          return;
        }

        final existingData = existingDocs.docs.first.data();
        final bool isActiveAccount =
            (existingData['is_active'] == true) || (existingData['isActive'] == true);

        if (isActiveAccount) {
          emit(AuthFailure('هذا البريد الإلكتروني مسجّل ومُفعّل بالفعل، يمكنك تسجيل الدخول مباشرة 👤'));
          return;
        }

        try {
          final pendingSignIn = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: tempEmail!.trim(),
            password: tempPassword!,
          );
          final String staleUid = pendingSignIn.user!.uid;

          try {
            await firestore.collection('users').doc(staleUid).delete();
            await firestore.collection('students').doc(staleUid).delete();
            await firestore.collection('parents').doc(staleUid).delete();
          } catch (_) {}

          await pendingSignIn.user!.delete();

          user = await _authService.signUpUser(
            name: tempName!,
            email: tempEmail!,
            password: tempPassword!,
            role: role,
          ).timeout(const Duration(seconds: 8));
        } on FirebaseAuthException {
          emit(AuthFailure(
            'يوجد حساب غير مكتمل بهذا البريد من محاولة سابقة. اكتب نفس كلمة المرور التي استخدمتها وقت التسجيل أول مرة لإكمال العملية، أو استخدم "نسيت كلمة المرور" من شاشة تسجيل الدخول.',
          ));
          return;
        }
      }

      if (user != null) {
        await firestore.collection('users').doc(user.uid).update({
          'otp_code': generatedOtp,
          'otp_created_at': FieldValue.serverTimestamp(),
        });

        if (role == 'student') {
          String stageCode = 'g1';
          if (grade == 'الصف الثاني الإعدادي') stageCode = 'g2';
          if (grade == 'الصف الثالث الإعدادي') stageCode = 'g3';
          String termCode = term == 'الترم الأول' ? 't1' : 't2';
          String freePackage = 'sci_${stageCode}_${termCode}';

          await firestore.collection('students').doc(user.uid).set({
            'name': tempName!.trim(),
            'email': tempEmail!.trim().toLowerCase(),
            'stage': grade ?? 'الصف الأول الإعدادي',
            'term': term ?? 'الترم الثاني',
            'isActive': false,
            'linkCode': 'FAHEM-${user.uid.substring(0, 5).toUpperCase()}',
            'unlockedPackages': [freePackage],
            'parentIds': [],
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (role == 'parent') {
          await firestore.collection('parents').doc(user.uid).set({
            'name': tempName!.trim(),
            'email': tempEmail!.trim().toLowerCase(),
            'isActive': false,
            'linkedStudents': [],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await _emailService.sendOTPEmail(
          targetEmail: tempEmail!,
          userName: tempName!,
          otpCode: generatedOtp,
        );

        emit(AuthOTPSent(uid: user.uid, email: tempEmail!));
      }
    } catch (e) {
      print('=== [AuthCubit Error 🚨] فشل إتمام الحساب: $e ===');
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  Future<void> verifyOTP(String uid, String enteredCode) async {
    emit(AuthLoading());
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        emit(AuthFailure('بيانات الحساب غير موجودة بقاعدة البيانات ❌'));
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final String? storedOtp = userData['otp_code'];
      final String userRole = userData['role'] ?? 'student';

      if (storedOtp == null || storedOtp.trim() != enteredCode.trim()) {
        emit(AuthFailure('كود التحقق الرقمي الذي أدخلته غير صحيح ❌'));
        return;
      }

      WriteBatch batch = firestore.batch();

      batch.update(firestore.collection('users').doc(uid), {
        'is_active': true,
        'isActive': true,
        'otp_code': FieldValue.delete(), 
        'otp_created_at': FieldValue.delete(),
      });

      if (userRole == 'parent') {
        batch.update(firestore.collection('parents').doc(uid), {
          'isActive': true,
          'is_active': true,
        });
      } else if (userRole == 'student') {
        batch.update(firestore.collection('students').doc(uid), {
          'isActive': true,
          'is_active': true,
        });
      }

      await batch.commit();

      emit(AuthSuccess(role: userRole));
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      String? role = await _authService.loginUser(email: email, password: password);
      if (role == null) {
        emit(AuthFailure('تعذر جلب صلاحيات المستخدم من الخادم ⚠️'));
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data() as Map<String, dynamic>?;
        final bool isActive = (data?['is_active'] == true) || (data?['isActive'] == true);

        if (!isActive) {
          final String newOtp = (1000 + Random().nextInt(9000)).toString();
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'otp_code': newOtp,
            'otp_created_at': FieldValue.serverTimestamp(),
          });

          final String userName = data?['name'] ?? 'مستخدم';
          await _emailService.sendOTPEmail(
            targetEmail: email.trim(),
            userName: userName,
            otpCode: newOtp,
          );

          emit(AuthOTPSent(uid: uid, email: email));
          return;
        }
      }

      emit(AuthSuccess(role: role));
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  Future<void> sendForgotPasswordOtp(String email) async {
    emit(AuthLoading());
    try {
      bool exists = await _authService.isEmailRegistered(email);
      if (!exists) {
        emit(AuthFailure('هذا البريد الإلكتروني غير مسجل لدينا في المنظومة ❌'));
        return;
      }

      tempForgotEmail = email.trim().toLowerCase();
      tempForgotOtp = (1000 + Random().nextInt(9000)).toString();

      await _emailService.sendOTPEmail(
        targetEmail: tempForgotEmail!,
        userName: "مستخدم فاهم",
        otpCode: tempForgotOtp!,
      );

      emit(AuthForgotOTPSent(tempForgotEmail!));
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  void verifyForgotPasswordOtp(String enteredCode) {
    emit(AuthLoading());
    if (enteredCode == tempForgotOtp) {
      emit(AuthForgotOTPVerified());
    } else {
      emit(AuthFailure('كود التحقق المكون من 4 أرقام غير صحيح ❌'));
    }
  }

  Future<void> resetUserPassword(String newPassword) async {
    emit(AuthLoading());
    try {
      if (tempForgotEmail == null) {
        emit(AuthFailure('انتهت الجلسة الأمنية، يرجى إعادة كتابة البريد الإلكتروني.'));
        return;
      }
      await _authService.updatePasswordInFirestore(tempForgotEmail!, newPassword);
      emit(AuthResetPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  Future<void> sendPasswordResetLink(String email) async {
    emit(AuthLoading());
    try {
      if (email.isEmpty) {
        emit(AuthFailure('يرجى كتابة البريد الإلكتروني أولاً.'));
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      emit(AuthResetPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  Future<void> checkCurrentSession() async {
    emit(AuthLoading());
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      emit(AuthInitial());
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        emit(AuthInitial());
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final bool isActive = (data['is_active'] == true) || (data['isActive'] == true);
      final String role = data['role'] ?? 'student';

      if (isActive) {
        emit(AuthSuccess(role: role));
      } else {
        emit(AuthOTPSent(uid: currentUser.uid, email: currentUser.email ?? ''));
      }
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  String _mapExceptionToFriendlyMessage(Object e) {
    final errorStr = e.toString().toLowerCase();

    if (errorStr.contains('invalid-credential') ||
        errorStr.contains('wrong-password') ||
        errorStr.contains('user-not-found')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة ❌';
    }
    if (errorStr.contains('invalid-email')) {
      return 'صيغة البريد الإلكتروني المكتوب غير صحيحة ✉️';
    }
    if (errorStr.contains('email-already-in-use')) {
      return 'هذا البريد الإلكتروني مستخدم بالفعل في حساب آخر 👥';
    }
    if (errorStr.contains('weak-password')) {
      return 'كلمة المرور ضعيفة للغاية، يرجى كتابة 6 أحرف أو أكثر 🔒';
    }
    if (errorStr.contains('network-request-failed')) {
      return 'فشل الاتصال بالإنترنت، يرجى التحقق من جودة الشبكة 🌐';
    }
    if (errorStr.contains('timeout')) {
      return 'انتهت مهلة الاتصال بالسيرفر، يرجى إعادة المحاولة مجدداً ⏳';
    }

    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.';
  }






  Future<void> resendOTP(String uid, String email) async {
  try {
    final String newOtp = (1000 + Random().nextInt(9000)).toString();
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'otp_code': newOtp,
      'otp_created_at': FieldValue.serverTimestamp(),
    });
    await _emailService.sendOTPEmail(
      targetEmail: email,
      userName: 'مستخدم فاهم',
      otpCode: newOtp,
    );
  } catch (_) {}
}
}