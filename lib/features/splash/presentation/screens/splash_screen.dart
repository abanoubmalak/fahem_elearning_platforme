// lib/features/splash/presentation/screens/splash_screen.dart
import 'dart:async';
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 استيراد مصادقة فايربيز
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 استيراد قاعدة البيانات للفحص الذكي
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup Status Bar (Make it transparent for full screen feel)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark icons for light background
      ),
    );

    // 2. Setup Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Fade in duration
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation
    _animationController.forward();

    // 3. نظام الفحص الذكي وحفظ الجلسة والتوجيه المعتمد على الأدوار 👈
    Timer(const Duration(seconds: 4), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          // جلب مستند المستخدم لمعرفة الـ role الفعلي المخزن بالـ Firestore
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          
          if (doc.exists && doc.data() != null) {
            String role = doc.get('role') ?? 'student';
            
            // التوجيه الحركي الصارم حسب صلاحيات الحساب الموثق
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, Routes.AdminMainWrapper);
            } else if (role == 'teacher') {
              Navigator.pushReplacementNamed(context, Routes.TeacherMainWrapper);
            } else if (role == 'parent') {
              Navigator.pushReplacementNamed(context, Routes.ParentWrapper);
            } else {
              Navigator.pushReplacementNamed(context, Routes.MainWrapper); // الطالب الافتراضي
            }
          } else {
            // إذا لم يوجد المستند يتم التصفير للشاشة الافتراضية للسلامة الأمنية
            Navigator.pushReplacementNamed(context, Routes.loginScreen);
          }
        } catch (e) {
          // في حال حدوث انقطاع بالشبكة يتم التوجيه لصفحة الدخول كحماية احتياطية
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
        }
      } else {
        // إذا لم يسجل دخوله مسبقاً، يفتح شاشة الدخول المعتادة
        Navigator.pushReplacementNamed(context, Routes.loginScreen);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 175,
                    height: 175,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "FAHEM",
                  style: TextStyle(
                    height: 0.8,
                    letterSpacing: 2,
                    fontSize: 65,
                    fontWeight: FontWeight.w900,
                    fontFamily: "Montserrat",
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "فاهم",
                  style: TextStyle(
                    height: 0.8,
                    fontSize: 105,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: "Cairo",
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Text(
                    'مش بس حافظ.. أنت فاهم',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreyColor,
                      fontFamily: 'Cairo',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "...جاري التحميل",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryColor.withAlpha(204),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}