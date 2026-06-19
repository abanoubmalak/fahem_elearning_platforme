// lib/features/forgot_password/presentation/screens/forgot_password_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان اتجاه الشاشة باللغة العربية
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            // حالة الفشل
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), 
                  backgroundColor: Colors.redAccent,
                ),
              );
            } 
            // حالة النجاح
            else if (state is AuthResetPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✅ تم إرسال رابط آمن لتغيير كلمة المرور إلى بريدك الإلكتروني، يرجى فحصه ثم تسجيل الدخول.', 
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Color(0xFF27AE60),
                  duration: Duration(seconds: 5),
                ),
              );
              // إرجاع المستخدم لشاشة تسجيل الدخول بعد النجاح
              Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'نسيت كلمة المرور؟ 🔒',
                        style: TextStyle(
                          fontFamily: 'Cairo', 
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا تقلق! أدخل بريدك الإلكتروني المسجل لدينا وسنرسل لك رابطاً آمناً لتعيين كلمة مرور جديدة في ثوانٍ.',
                        style: TextStyle(
                          fontFamily: 'Cairo', 
                          fontSize: 14, 
                          color: Colors.grey[600], 
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // ── حقل البريد الإلكتروني ──
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 22),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال البريد الإلكتروني';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'صيغة البريد الإلكتروني غير صحيحة';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // ── زر إرسال الرابط ──
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              // استدعاء دالة إرسال الرابط من الفايربيز
                              context.read<AuthCubit>().sendPasswordResetLink(_emailController.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  'إرسال رابط الاستعادة', 
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}