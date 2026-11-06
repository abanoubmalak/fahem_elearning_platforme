import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/helpers/app_validator.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: Image.asset("assets/images/logo.png", width: 150, height: 150),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('مش بس حافظ.. أنت فاهم', style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkGreyColor)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  validator: AppValidator.validateFullName,
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'الاسم الكامل',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 15.0, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    prefixIcon: const Icon(Icons.person, size: 30, color: AppColors.primaryTeal),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: AppValidator.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني ',
                    hintStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    prefixIcon: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.email_rounded, size: 30, color: AppColors.primaryTeal)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: AppValidator.validatePassword,
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.right,
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
                    prefixIcon: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.lock_rounded, size: 30, color: AppColors.primaryTeal)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'برجاء تأكيد كلمة المرور';
                    if (value != _passwordController.text) return 'كلمات المرور غير متطابقة ❌';
                    return null;
                  },
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'تأكيد كلمة المرور',
                    hintStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 30, color: AppColors.primaryTeal),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    prefixIcon: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.lock_rounded, size: 30, color: AppColors.primaryTeal)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3)),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      cubit.saveBasicInfo(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      Navigator.pushNamed(context, Routes.RoleSelectionScreen); // الانتقال للخطوة 2
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), elevation: 0),
                  child: const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.loginScreen),
                      child: const Text(' تسجيل الدخول', style: TextStyle(fontSize: 16, color: Color(0xFF269A9E), fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                    const Text('لديك حساب بالفعل؟', style: TextStyle(color: Colors.black, fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  super.dispose();
}
}