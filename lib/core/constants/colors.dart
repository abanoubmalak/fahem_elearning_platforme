

// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 1. الألوان الأساسية للهوية البصرية (Brand Colors)
  static const Color primary = Color(0xFF269A9E);       // الفيروزي الأساسي للتطبيق
  static const Color accentGold = Color(0xFFD4AF37);    // الذهبي الخفيف للتنبيهات والشعارات
  static const Color primaryLight = Color(0xFFE0F2F1);  // فيروزي فاتح جداً لخلفيات الأيقونات والكروت

  // 2. ألوان واجهة المستخدم الثابتة (UI Colors)
  static const Color scaffoldBackground = Color(0xFFF7FBFB); // خلفية التطبيق البيضاء المائلة للفيروزي
  static const Color cardBackground = Colors.white;          // لون خلفية الكروت الافتراضي

  // 3. ألوان النصوص والرموز (Text & Icon Colors)
  static const Color textMain = Color(0xFF454545);      // اللون الأسود المريح للعين (العناوين والنصوص الأساسية)
  static const Color textGrey = Colors.grey;            // اللون الرمادي للنصوص الفرعية والنسب المئوية

  // 4. إعدادات الظلال الموحدة للكروت (Drop Shadows)
  // تم فصلها هنا لضمان أن جميع الكروت في "الرئيسية" و"دوراتي" لها نفس التأثير البصري الاحترافي
  static List<BoxShadow> commonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];


  static const Color primaryTeal = Color(0xFF007A7C);
  static const Color backgroundTop = Color(0xFF00A8AD);
  static const Color backgroundBottom = Color(0xFF005F61);
  static const Color primaryColor = Color(0xFF0097A7); // Turquoise/Aqua Blue
  static const Color darkGreyColor = Color(0xFF454545);
}