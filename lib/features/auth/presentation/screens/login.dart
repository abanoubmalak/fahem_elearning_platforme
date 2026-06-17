// lib/features/auth/presentation/screens/login.dart
import "package:fahem/core/constants/colors.dart";
import "package:fahem/core/helpers/app_validator.dart";
import "package:fahem/core/routing/routes.dart";
import "package:fahem/features/auth/presentation/cubit/auth_cubit.dart";
import "package:fahem/features/auth/presentation/cubit/auth_state.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: Image.asset("assets/images/logo.png", width: 150, height: 150),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'مش بس حافظ.. أنت فاهم',
                      style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkGreyColor, wordSpacing: 0.5),
                    ),
                    const SizedBox(height: 60),
                    
                    // ==================== 1. حقل البريد الإلكتروني ====================
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.right,
                      validator: AppValidator.validateEmail,
                      decoration: InputDecoration(
                        hintText: 'البريد الإلكتروني ',
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

                    const SizedBox(height: 30),

                    // ==================== 2. حقل كلمة المرور ====================
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textAlign: TextAlign.right,
                      validator: AppValidator.validatePassword,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        hintStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 30, color: AppColors.primaryTeal),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.lock_rounded, size: 30, color: AppColors.primaryTeal),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3)),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ==================== 3. إدارة الحالات والتوجيه بالـ BlocConsumer ====================
                    BlocConsumer<AuthCubit, AuthState>(
                      listenWhen: (previous, current) => current is AuthSuccess || current is AuthFailure,
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          // التوجيه الذكي والشامل لكل مستخدم حسب صلاحياته الموثقة
                          if (state.role == 'admin') {
                            Navigator.pushNamedAndRemoveUntil(context, Routes.AdminMainWrapper, (route) => false);
                          } else if (state.role == 'teacher') {
                            Navigator.pushNamedAndRemoveUntil(context, Routes.TeacherMainWrapper, (route) => false);
                          } else if (state.role == 'parent') {
                            Navigator.pushNamedAndRemoveUntil(context, Routes.ParentWrapper, (route) => false);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(context, Routes.MainWrapper, (route) => false);
                          }
                        } else if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent)
                          );
                        }
                      },
                      buildWhen: (previous, current) => current is AuthFailure || current is AuthLoading || current is AuthSuccess,
                      builder: (context, state) {
                        bool isLoading = (state is AuthLoading);

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    // الاستدعاء الهندسي السليم والآمن من الـ context مباشرة لإنهاء الـ Undefined 👈
                                    context.read<AuthCubit>().loginWithEmailAndPassword(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            minimumSize: const Size(double.infinity, 65),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ==================== 4. روابط التنقل الفرعية ====================
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.forgotPasswordScreen);
                      },
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 10),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.forum, color: AppColors.primaryTeal, size: 35),
                          onPressed: () {
                            // وظيفة الدعم الفني المستقبلية
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text.rich(
                      TextSpan(
                        text: 'ليس لديك حساب؟ ',
                        style: const TextStyle(color: Colors.black, fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: 'إنشاء حساب',
                            style: const TextStyle(color: AppColors.primaryTeal, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, Routes.signUpScreen);
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}