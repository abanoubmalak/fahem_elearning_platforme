// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ التحقق من صلاحية الإيميل قبل أي عملية
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  // دالة إنشاء حساب جديد
  Future<User?> signUpUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // ✅ رفض الإيميلات الوهمية قبل أي طلب لـ Firebase
    if (!_isValidEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'صيغة البريد الإلكتروني غير صحيحة',
      );
    }

    UserCredential? credential;
    try {
      // 1. إنشاء الحساب في Firebase Auth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      if (credential.user == null) return null;

      // 2. بناء مستند البيانات
      final Map<String, dynamic> userData = {
        'uid': credential.user!.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password.trim(),
        'role': role.trim(),
        'is_active': false,
        'isActive': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (role.trim() == 'parent') {
        userData['linked_children'] = [];
      }

      // 3. حفظ في Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData)
          .timeout(const Duration(seconds: 5));

      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      // ✅ لو فشل حفظ Firestore — نمسح حساب Firebase عشان مايفضلش معلّق
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {}
      }
      print('=== [AuthService 🚨] استثناء غير متوقع: $e ===');
      rethrow;
    }
  }

  // تسجيل الدخول
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.get('role') ?? 'student';
        }
      }
      return 'student';
    } catch (e) {
      rethrow;
    }
  }

  // فحص وجود الإيميل في قاعدة البيانات
  Future<bool> isEmailRegistered(String email) async {
    final String cleanEmail = email.trim().toLowerCase();
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: cleanEmail)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // التحقق من كود OTP
  Future<bool> verifyUserOTP(String uid, String enteredCode) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final savedOtp = data['otp_code'];

      if (savedOtp == null || savedOtp != enteredCode.trim()) return false;

      // تفعيل الحساب ومسح الكود
      await _firestore.collection('users').doc(uid).update({
        'is_active': true,
        'isActive': true,
        'otp_code': FieldValue.delete(),
        'otp_created_at': FieldValue.delete(),
      });

      return true;
    } catch (e) {
      print('verifyUserOTP Error: $e');
      return false;
    }
  }

  // تحديث كلمة المرور في Firestore
  Future<void> updatePasswordInFirestore(
    String email,
    String newPassword,
  ) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('المستخدم غير موجود');
    }

    await _firestore
        .collection('users')
        .doc(query.docs.first.id)
        .update({'password': newPassword.trim()});
  }
}