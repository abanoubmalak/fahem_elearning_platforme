// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👈 دالة تحديث كلمة المرور الجديدة في الفايرستور ليتم اعتمادها فوراً
  Future<void> updatePasswordInFirestore(
    String email,
    String newPassword,
) async {

  final query = await _firestore
      .collection('users')
      .where('email',
          isEqualTo: email.trim().toLowerCase())
      .get();

  if (query.docs.isEmpty) {
    throw Exception('المستخدم غير موجود');
  }

  await _firestore
      .collection('users')
      .doc(query.docs.first.id)
      .update({
    'password': newPassword.trim(),
  });


  // استدعاء Cloud Function لتغيير Firebase Auth
}

  // فحص وجود الحساب
  Future<bool> isEmailRegistered(String email) async {
    String cleanEmail = email.trim();
    var queryExact = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
    if (queryExact.docs.isNotEmpty) return true;
    var queryLower = await _firestore.collection('users').where('email', isEqualTo: cleanEmail.toLowerCase()).get();
    return queryLower.docs.isNotEmpty;
  }

  // إنشاء حساب جديد
  // lib/core/services/auth_service.dart

  // دالة إنشاء حساب جديد وتوثيق كلمة المرور ديناميكياً في الفايرستور
  Future<User?> signUpUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 1. إنشاء الحساب في خادم الـ Authentication الأساسي
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      if (credential.user != null) {
        // 2. بناء مستند البيانات بشكل صريح وآمن هندسياً 👈
        Map<String, dynamic> userData = {
          'uid': credential.user!.uid,
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password.trim(), // حفظ الباسورد لتطابق الواجهات المخصصة لاحقاً
          'role': role.trim(),
          'is_active': false, // لا ينشط الحساب إلا بعد الـ OTP
        };

        // إدارة مصفوفة الأبناء فقط إذا كان المستخدم ولي أمر
        if (role.trim() == 'parent') {
          userData['linked_children'] = [];
        }

        // 3. رفع المستند إلى كوليكشن users بالـ Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData)
            .timeout(const Duration(seconds: 5));
      }
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('=== [AuthService 🚨] خطأ فايربيز أثناء التسجيل: ${e.code} ===');
      rethrow;
    } catch (e) {
      print('=== [AuthService 🚨] استثناء غير متوقع: $e ===');
      rethrow;
    }
  }

  // 👈 تعديل دالة تسجيل الدخول لتفهم وتطابق كلمة المرور الجديدة المحدثة سحابياً
  Future<String?> loginUser({required String email, required String password}) async {
    try {
      // 1. الاتصال الرسمي بـ FirebaseAuth لتوليد الجلسة وحفظ الـ Token على الجهاز 👈
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. إذا نجح الدخول، نجلب الـ Role من الفايرستور
      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.get('role') ?? 'student'; // إرجاع الصلاحية لتوجيه المستخدم
        }
      }
      return 'student'; // صلاحية افتراضية أمان
      
    } catch (e) {
      // تمرير الخطأ للـ AuthCubit لترجمته وعرضه
      rethrow; 
    }
  }
  // مراجعة رمز الـ OTP
  Future<bool> verifyUserOTP(String uid, String enteredCode) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 3));
      if (doc.exists) {
        await _firestore.collection('users').doc(uid).update({'is_active': true});
        return doc.get('otp_code') == enteredCode;
      }
    } catch (_) { return true; }
    return false;
  }
}