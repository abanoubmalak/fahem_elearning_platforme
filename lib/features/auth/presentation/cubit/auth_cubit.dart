// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'dart:math';
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

  // حفظ البيانات بالذاكرة مؤقتاً بين شاشات التسجيل
  void saveBasicInfo({required String name, required String email, required String password}) {
    tempName = name;
    tempEmail = email;
    tempPassword = password;
  }

 // lib/features/auth/presentation/cubit/auth_cubit.dart

  // دالة إتمام التسجيل وتوليد الـ OTP بعد إدخال الـ Role والبيانات الدراسية
  Future<void> completeRegistration({required String role, String? grade, String? term}) async {
    emit(AuthLoading());
    try {
      if (tempEmail == null || tempName == null || tempPassword == null) {
        emit(AuthFailure('بيانات الحساب الأساسية مفقودة، يرجى إعادة المحاولة ⚠️'));
        return;
      }

      print('=== [AuthCubit] جاري بدء التسجيل السحابي للمستخدم: $tempName ===');
      String generatedOtp = (1000 + Random().nextInt(9000)).toString(); // كود رباعي موحد

      // استدعاء دالة السيرفر وتمرير المتغيرات الصريحة بدلاً من (this) 👈
      var user = await _authService.signUpUser(
        name: tempName!,
        email: tempEmail!,
        password: tempPassword!,
        role: role,
      ).timeout(const Duration(seconds: 8)); 

      if (user != null) {
        // إرسال بريد التحقق الرقمي عبر خدمة EmailJS
        await _emailService.sendOTPEmail(
          targetEmail: tempEmail!, 
          userName: tempName!, 
          otpCode: generatedOtp
        );
        
        emit(AuthOTPSent(uid: user.uid, email: tempEmail!));
      }
    } catch (e) {
      print('=== [AuthCubit Error 🚨] فشل إتمام الحساب: $e ===');
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e))); // تعريب الأخطاء بشكل موحد
    }
  }

  // التحقق من كود الـ OTP لحساب جديد
  Future<void> verifyOTP(String uid, String enteredCode) async {
    emit(AuthLoading());
    try {
      bool isCorrect = await _authService.verifyUserOTP(uid, enteredCode);
      if (isCorrect) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('كود التحقق الرقمي الذي أدخلته غير صحيح ❌'));
      }
    } catch (e) { 
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e))); 
    }
  }

  // تسجيل الدخول بالبريد وكلمة المرور
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      String? role = await _authService.loginUser(email: email, password: password);
      if (role != null) {
        emit(AuthSuccess(role: role)); 
      } else {
        emit(AuthFailure('تعذر جلب صلاحيات المستخدم من الخادم ⚠️'));
      }
    } catch (e) { 
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e))); // منع تسريب invalid-credential حياً
    }
  }

  // إرسال كود استعادة كلمة المرور بالفحص الاستباقي الصارم
  Future<void> sendForgotPasswordOtp(String email) async {
    emit(AuthLoading());
    try {
      print('=== [AuthCubit] بدء الفحص الاستباقي للبريد: $email ===');
      
      // 1. الفحص الصارم في الفايرستور
      bool exists = await _authService.isEmailRegistered(email);
      
      if (!exists) {
        emit(AuthFailure('هذا البريد الإلكتروني غير مسجل لدينا في المنظومة ❌'));
        return;
      }

      // 2. إذا نجح الفحص نولد كود رباعي متناسق مع شاشتك الجديدة
      tempForgotEmail = email.trim().toLowerCase();
      tempForgotOtp = (1000 + Random().nextInt(9000)).toString(); // 👈 توليد 4 أرقام بدقة

      bool isEmailSent = await _emailService.sendOTPEmail(
        targetEmail: tempForgotEmail!,
        userName: "مستخدم فاهم",
        otpCode: tempForgotOtp!,
      );

      if (isEmailSent) {
        print('=== [AuthCubit] تم إرسال كود استعادة كلمة المرور بنجاح 🎉 ===');
      } else {
        print('=== [وضع المحاكاة الآمن]: الكود هو: $tempForgotOtp ===');
      }
      
      emit(AuthForgotOTPSent(tempForgotEmail!)); 
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  // التحقق من كود استعادة الباسورد الرباعي الجديد
  void verifyForgotPasswordOtp(String enteredCode) {
    emit(AuthLoading());
    if (enteredCode == tempForgotOtp) {
      emit(AuthForgotOTPVerified());
    } else {
      emit(AuthFailure('كود التحقق المكون من 4 أرقام غير صحيح ❌')); // 👈 تم التحديث لـ 4 أرقام
    }
  }

  // حفظ وتحديث كلمة المرور الجديدة حياً في قاعدة البيانات
  Future<void> resetUserPassword(String newPassword) async {
    emit(AuthLoading());
    try {
      if (tempForgotEmail == null) {
        emit(AuthFailure('انتهت الجلسة الأمنية، يرجى إعادة كتابة البريد الإلكتروني.'));
        return;
      }

      print('=== [AuthCubit 🔐] جاري استدعاء السيرفر لتحديث كلمة المرور للإيميل: $tempForgotEmail ===');
      
      await _authService.updatePasswordInFirestore(tempForgotEmail!, newPassword);
      
      print('=== [AuthCubit 🎉] تم تحديث كلمة المرور بنجاح في قاعدة البيانات ===');
      emit(AuthResetPasswordSuccess()); 
    } catch (e) {
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e)));
    }
  }

  // ==================== 🛠️ الدالة المركزية المحدثة لترجمة وتوطين الأخطاء ====================
  String _mapExceptionToFriendlyMessage(Object e) {
    final errorStr = e.toString().toLowerCase();
    
    // فحص شامل ومرن لكافة أكواد أخطاء الهوية وباسوردات التحقق المدمجة
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
}