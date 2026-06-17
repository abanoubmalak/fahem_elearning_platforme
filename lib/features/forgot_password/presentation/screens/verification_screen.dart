// lib/features/forgot_password/presentation/screens/verification_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_state.dart';
import 'dart:async'; // 👈 مطلوب لتشغيل الـ Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // 👈 متغيرات العداد التنازلي لإعادة الإرسال
  late Timer _timer;
  int _secondsRemaining = 59;
  bool _canResend = false;

  // تقليص المصفوفات هندسياً لـ 4 أرقام فقط 
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startTimer(); // بدء العداد التنازلي فور فتح الشاشة
  }

  // دالة تشغيل وإعادة تهيئة العداد التنازلي
  void _startTimer() {
    setState(() { _secondsRemaining = 59; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) { 
        setState(() { _secondsRemaining--; }); 
      } else { 
        setState(() { _canResend = true; _timer.cancel(); }); 
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // إلغاء التايمر من الذاكرة لمنع الـ Memory Leak
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthForgotOTPVerified) {
            Navigator.pushNamed(context, Routes.ResetPasswordScreen);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
          }
        },
        builder: (context, state) {
          bool isLoading = state is AuthLoading;

          return Center(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30.0),
                      const Icon(Icons.mark_email_read_outlined, size: 150, color: Color(0xFF269A9E)),
                      const SizedBox(height: 30),
                      const Text("تحقق من بريدك الإلكتروني", style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.darkGreyColor)),
                      const SizedBox(height: 10),
                      // تحديث النص ليعكس الـ 4 أرقام الجديدة 👈
                      const Text("أدخل رمز التحقق المكون من 4 أرقام المرسل إلى بريدك", textAlign: TextAlign.center, style: TextStyle(color: AppColors.darkGreyColor, fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 14)),
                      const SizedBox(height: 30),
                      
                      // توزيع الـ 4 صناديق بـأبعاد متناسقة من اليسار لليمين (LTR)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => _buildSingleOtpBox(index)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
                          String fullCode = _controllers.map((c) => c.text).join();
                          if (fullCode.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('من فضلك أدخل كود التحقق كاملاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                            return;
                          }
                          cubit.verifyForgotPasswordOtp(fullCode); 
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), elevation: 0),
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text("متابعة", style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 30),
                      
                      // الـ Row المطور ديناميكياً ليدعم العداد التنازلي لإعادة الإرسال 👈
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _canResend
                              ? TextButton(
                                  onPressed: () {
                                    _startTimer(); // إعادة تشغيل التايمر
                                    cubit.sendForgotPasswordOtp(cubit.tempForgotEmail ?? ""); // طلب كود جديد حياً
                                  }, 
                                  child: const Text(
                                    "إعادة الإرسال", 
                                    style: TextStyle(color: Color(0xFF269A9E), fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 18)
                                  )
                                )
                              : Text(
                                  '00:${_secondsRemaining.toString().padLeft(2, '0')}', 
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))
                                ),
                          const SizedBox(width: 8),
                          Text(
                            _canResend ? "لم يصلك الرمز؟" : "يمكنك إعادة طلب الرمز خلال",
                            style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkGreyColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50,)
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  // باني الصناديق الرباعية مع الفوكس الذكي المحدث
  Widget _buildSingleOtpBox(int index) {
    return SizedBox(
      width: 56, // زيادة العرض قليلاً ليناسب المساحة الأفقية بعد حذف خانتين
      height: 58,
      child: TextField(
        controller: _controllers[index], focusNode: _focusNodes[index],
        textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "", filled: true, fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2.5))
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (index < 3) { // 👈 التعديل لـ 4 خانات (الحد الأقصى index 3)
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]); 
            } else { 
              _focusNodes[index].unfocus(); 
            }
          } else if (value.isEmpty) {
            if (index > 0) { 
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]); 
            }
          }
        },
      ),
    );
  }
}