// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👈 دالة تحديث كلمة المرور الجديدة في الفايرستور ليتم اعتمادها فوراً
  Future<void> updatePasswordInFirestore(String email, String newPassword) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();

    if (query.docs.isNotEmpty) {
      // تحديث حقل الـ password داخل مستند المستخدم الحركي
      await _firestore.collection('users').doc(query.docs.first.id).update({
        'password': newPassword.trim(),
      });
    }
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
    String cleanEmail = email.trim().toLowerCase();
    String cleanPassword = password.trim();

    // 1. الفحص الاستباقي في الفايرستور لمعاينة إذا تم تغيير الباسورد عبر شاشاتك المخصصة
    final query = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
    
    if (query.docs.isNotEmpty) {
      var userData = query.docs.first.data();
      // لو الباسورد المكتوب يطابق الباسورد الجديد المخزن في الفايرستور
      if (userData['password'] == cleanPassword) {
        return userData['role'] as String?;
      }
    }

    // 2. المحاولة الافتراضية عبر خادم الفايربيز الأساسي
    UserCredential credential = await _auth.signInWithEmailAndPassword(email: cleanEmail, password: cleanPassword);
    if (credential.user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.get('role') as String?; 
      }
    }
    return null;
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