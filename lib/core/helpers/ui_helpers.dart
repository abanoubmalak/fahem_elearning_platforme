// lib/core/helpers/ui_helpers.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class UiHelpers {
  static void showSubscriptionPaywall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.lock_rounded, color: Color(0xFFE6A100), size: 48),
              SizedBox(height: 12),
              Text('المحتوى مغلق', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: const Text(
            'هذا المحتوى متاح فقط للمشتركين. يرجى تزويد ولي الأمر بكود الربط الخاص بك لتفعيل الباقة وفتح جميع الدروس والاختبارات.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textMain, height: 1.5),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text('حسناً، فهمت', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}