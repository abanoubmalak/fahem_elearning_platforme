

import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/forgot_password/presentation/screens/reset_password_screen.dart';
import 'package:fahem/features/forgot_password/presentation/widgets/otp_boxt.dart';
import 'package:fahem/features/login/presentation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState()=>_VerificationSecreen();
}


class _VerificationSecreen extends State<VerificationScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child: SafeArea(
          child:SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              
                  SizedBox(height: 30.0,),
              
                  Icon(Icons.mark_email_read_outlined, size: 150, color: Color(0xFF269A9E)),
              
                  SizedBox(height: 30),
              
                  Text(
                    "تحقق من بريدك الإلكتروني", 
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreyColor,
                      )
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "أدخل رمز التحقق المكون من 6 أرقام المرسل إلى بريدك", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color:AppColors.darkGreyColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cairo",
                      fontSize: 16)
                    ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => OtpBix()),
                  ),
                  SizedBox(height: 20,),

                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> ResetPasswordScreen())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      minimumSize: const Size(double.infinity, 65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                      ),
                      elevation: 0
                    ),
                    child: Text(
                      "متابعة",
                      style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {}, 
                          child: Text(
                            "إعادة الإرسال", 
                            style: TextStyle(
                              color: Color(0xFF269A9E),
                              fontFamily: "Cairo",
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                          )
                        ),

                        Text(
                          "لم يصلك الرمز؟",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                          ),
                      ],
                    ),

                    SizedBox(height: 100,)
                ],
              ),
            ),
          )
          
          ),
      )
    );
  }
}