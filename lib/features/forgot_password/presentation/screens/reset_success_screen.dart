import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/screens/login.dart';
import 'package:flutter/material.dart';

class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ClipRRect(
                  //     borderRadius: BorderRadius.circular(1),
                  //     child: Image.asset("assets/images/logo.png",
                  //       width: 150,
                  //       height: 150 ,
                  //     ),
                  //   ),

                  const SizedBox(height: 30),

                  const Text(
                   '! تم تغيير كلمة المرور بنجاح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF454545),
                      fontFamily: 'Cairo',
                    ),
                  ),
              
                  const SizedBox(height: 60),

                  Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1), // لون فيروزي فاتح جداً
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 80,
                    color: Color(0xFF269A9E),
                  ),
                ),
                SizedBox(height: 50,),
                
              
                  const Text(
                    'مبروك يا بطل! كلمة مرورك الجديدة جاهزة الآن للاستخدام في تطبيق فاهم. يمكنك الآن تسجيل الدخول والبدء في استكمال تقدمك الدراسي.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'Cairo',
                      height: 1.6,
                      fontWeight: FontWeight.w200
                    ),
                  ),

                  SizedBox(height: 30,),
              
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.loginScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF269A9E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'تسجيل الدخول الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}