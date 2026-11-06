import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_state.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String uid;

  const OtpVerificationScreen({super.key, required this.email, required this.uid});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  Timer? _timer;
  int _secondsRemaining = 59;
  bool _canResend = false;

  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _cancelAndGoToLogin() async {
    _timer?.cancel();
    try {
      await FirebaseAuth.instance.signOut(); 
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.loginScreen,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.24;
    final cubit = BlocProvider.of<AuthCubit>(context);

    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (!didPop) _cancelAndGoToLogin();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        resizeToAvoidBottomInset: true,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تفعيل الحساب بنجاح! 🎉', style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Colors.green,
                  ),
                );
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
                  SnackBar(content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                );
              }
            },
            builder: (context, state) {
              bool isLoading = state is AuthLoading;

              return Stack(
                children: [
                  Positioned(
                    top: 0, left: 0, right: 0, height: headerHeight,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                  onPressed: _cancelAndGoToLogin,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'تأكيد الحساب الرقمي',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: headerHeight + 30),
                          const CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.mark_email_read_outlined, size: 45, color: Color(0xFF005F61)),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                const Text('أدخل رمز التحقق', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                                const SizedBox(height: 10),
                                Text(
                                  'قمنا بإرسال كود التحقق المكون من 4 أرقام إلى بريدك الإلكتروني المستقر بالأسفل:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[600], height: 1.5),
                                ),
                                const SizedBox(height: 6),
                                Text(widget.email, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(4, (index) => _buildOtpBox(index)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _canResend ? 'لم يصلك الكود؟ ' : 'يمكنك إعادة طلب الكود خلال ',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey),
                              ),
                              _canResend
                                  ? TextButton(
                                      onPressed: () {
                                        cubit.resendOTP(widget.uid, widget.email); // ✅ إعادة إرسال حقيقية
                                        _startTimer();
                                      },
                                      child: const Text(
                                        'إعادة إرسال الرمز',
                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE6A100)),
                                      ),
                                    )
                                  : Text(
                                      '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE6A100)),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        String otpCode = _controllers.map((c) => c.text).join();
                                        if (otpCode.length < 4) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('من فضلك أدخل كود التحقق كاملاً', style: TextStyle(fontFamily: 'Cairo')),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                          return;
                                        }
                                        cubit.verifyOTP(widget.uid, otpCode);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005F61),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('تأكيد الحساب وتفعيل', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 56,
      height: 58,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (index < 3) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty) {
            if (index > 0) FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }
}