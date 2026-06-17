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
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthForgotOTPSent) {
            // 👈 التوجيه الحركي الذكي: لا ننتقل إلا عند نجاح الفحص وإرسال الرمز
            Navigator.pushNamed(context, Routes.VerificationScreen);
          } else if (state is AuthFailure) {
            // عرض رسالة الخطأ الحمراء الصريحة للجنة إذا كان الإيميل غير موجود
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), 
                backgroundColor: Colors.redAccent
              ),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Icon(Icons.lock_reset, size: 150, color: Color(0xFF269A9E)),
                        const SizedBox(height: 20),
                        const Text(
                          "نسيت كلمة المرور؟",
                          style: TextStyle(fontFamily: "Cairo", fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkGreyColor),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          textAlign: TextAlign.center,
                          "أدخل بريدك الإلكتروني لتلقي رمز إعادة التعيين المكون من 6 أرقام", 
                          style: TextStyle(color: AppColors.darkGreyColor, fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.right,
                          validator: (val) => (val == null || !val.contains('@')) ? 'برجاء إدخال بريد إلكتروني صحيح' : null,
                          decoration: InputDecoration(
                            hintText: "أدخل بريدك الإلكتروني",
                            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.email_rounded, size: 30, color: AppColors.primaryTeal),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // زر الإرسال المربوط بحالة التحميل
                        SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () {
                              if (_formKey.currentState!.validate()) {
                                // استدعاء فحص وجود البريد وإرسال الرمز 👈
                                cubit.sendForgotPasswordOtp(_emailController.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : const Text("إرسال الرمز الرقمي", style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, Routes.loginScreen),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 20, color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                              Text("العودة لتسجيل الدخول ", style: TextStyle(color: AppColors.primaryTeal, fontFamily: "Cairo", fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}