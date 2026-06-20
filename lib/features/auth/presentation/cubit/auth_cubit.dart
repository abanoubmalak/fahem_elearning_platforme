// lib/features/auth/presentation/cubit/auth_cubit.dart
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

  // حفظ البيانات بالذاكرة مؤقتاً بين شاشات التسجيل
  void saveBasicInfo({required String name, required String email, required String password}) {
    tempName = name;
    tempEmail = email;
    tempPassword = password;
  }

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

      // 1. إنشاء الحساب في Authentication وجدول users
      var user = await _authService.signUpUser(
        name: tempName!,
        email: tempEmail!,
        password: tempPassword!,
        role: role,
      ).timeout(const Duration(seconds: 8)); 

      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        
        if (role == 'student') {
           String stageCode = 'g1';
           if (grade == 'الصف الثاني الإعدادي') stageCode = 'g2';
           if (grade == 'الصف الثالث الإعدادي') stageCode = 'g3';
           String termCode = term == 'الترم الأول' ? 't1' : 't2';
           String freePackage = 'sci_${stageCode}_${termCode}'; // فتح العلوم كعينة تجريبية

           await firestore.collection('students').doc(user.uid).set({
             'name': tempName!.trim(),
             'email': tempEmail!.trim().toLowerCase(),
             'stage': grade ?? 'الصف الأول الإعدادي',
             'term': term ?? 'الترم الثاني',
             'isActive': false, // لن يتفعل إلا بعد إدخال الـ OTP
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

        // 3. إرسال بريد التحقق الرقمي عبر خدمة EmailJS
        await _emailService.sendOTPEmail(
          targetEmail: tempEmail!, 
          userName: tempName!, 
          otpCode: generatedOtp
        );
        
        emit(AuthOTPSent(uid: user.uid, email: tempEmail!));
      }
    } catch (e) {
      print('=== [AuthCubit Error 🚨] فشل إتمام الحساب: $e ===');
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e))); 
    }
  }

  // 💎 تحديث منطق التحقق من كود الـ OTP لحساب جديد والتوجيه الذكي الموحد 💎
  Future<void> verifyOTP(String uid, String enteredCode) async {
    emit(AuthLoading());
    try {
      // 1. فحص صحة الكود عبر السيرفر الخاص بك
      bool isCorrect = await _authService.verifyUserOTP(uid, enteredCode);
      
      if (isCorrect) {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // 2. جلب مستند المستخدم الأساسي لمعرفة الـ role الفعلي سحابياً
        DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
        if (!userDoc.exists) {
          emit(AuthFailure('بيانات الحساب غير موجودة بقاعدة البيانات ❌'));
          return;
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final String userRole = userData['role'] ?? 'student'; // استخراج الدور الحقيقي الحركي

        // 3. تحديث تزامني موحد لحالة التفعيل (Activation) لمنع أي تضارب بين الحقول والتعارض البصري
        WriteBatch batch = firestore.batch();

        // تحديث جدول الـ users الموحد (دعم الحقلين معاً لتأمين الاستقرار البصري)
        batch.update(firestore.collection('users').doc(uid), {
          'is_active': true,
          'isActive': true,
        });

        // تحديث الجدول الفرعي المخصص حسب الصلاحية الفعلية
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

        // إتمام الحفظ السحابي دفعة واحدة بنظام الـ Batch
        await batch.commit();

        // 4. بث حالة النجاح مع تمرير الـ role الحقيقي للتوجيه السليم فوراً
        emit(AuthSuccess(role: userRole));
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
      emit(AuthFailure(_mapExceptionToFriendlyMessage(e))); 
    }
  }

  // إرسال كود استعادة كلمة المرور بالفحص الاستباقي الصارم
  Future<void> sendForgotPasswordOtp(String email) async {
    emit(AuthLoading());
    try {
      print('=== [AuthCubit] بدء الفحص الاستباقي للبريد: $email ===');
      
      bool exists = await _authService.isEmailRegistered(email);
      if (!exists) {
        emit(AuthFailure('هذا البريد الإلكتروني غير مسجل لدينا في المنظومة ❌'));
        return;
      }

      tempForgotEmail = email.trim().toLowerCase();
      tempForgotOtp = (1000 + Random().nextInt(9000)).toString(); // توليد 4 أرقام بدقة

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
      emit(AuthFailure('كود التحقق المكون من 4 أرقام غير صحيح ❌')); 
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

  // الدالة المركزية لترجمة وتوطين الأخطاء
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

  // دالة نسيان كلمة المرور (الطريقة الرسمية لفايربيز)
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
}