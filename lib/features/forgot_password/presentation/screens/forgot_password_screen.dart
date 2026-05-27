import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/forgot_password/presentation/screens/verification_screen.dart';
import 'package:fahem/features/login/presentation/screens/login.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget{
  const ForgotPasswordScreen({super.key});

  @override
  State <ForgotPasswordScreen> createState()=> _ForgotPasswordScreen();

}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen>{

  final _emailController=TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(1),
                  //   child: Image.asset("assets/images/logo.png",
                  //     width: 150,
                  //     height: 150 ,
                  //   ),
                  // ),

                  Icon(Icons.lock_reset, size: 150, color: Color(0xFF269A9E)),
                  SizedBox(height: 20,),
                  Text(
                    "نسيت كلمة المرور؟",
                    style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGreyColor,
                    )
                  ),
                  SizedBox(height: 20,),
                  Text(
                    textAlign: TextAlign.center,
                    "أدخل بريدك الإلكتروني لتلقي رابط إعادة التعيين", 
                    style: TextStyle(
                      
                      color:AppColors.darkGreyColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cairo",
                      fontSize: 18
                      )
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller:_emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                
                    decoration: InputDecoration(
                      hintText: "أدخل بريدك الإلكتروني",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color:Colors.grey,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold
                      ),
                
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.email_rounded,size:30,color:AppColors.primaryTeal),
                      ),
                
                      filled:true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                
                      enabledBorder: OutlineInputBorder(
                        borderRadius:  BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: AppColors.primaryTeal,width: 2)
                      ),
                
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: AppColors.primaryTeal,width: 3)
                      )
                    ),
                  ),
          
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context)=> const VerificationScreen())
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
                      "إرسال الرابط",
                      style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30,),
                  TextButton(
                    onPressed: (){}, 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,size:20,color: AppColors.primaryTeal,fontWeight: FontWeight.bold,),
                        TextButton(
                          onPressed: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context)=> const LoginScreen())
                            );
                          },
                          child: Text(
                            "العودة لتسجيل الدخول ", 
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontFamily: "Cairo",
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                              )
                          ),
                          ),
                      ],
                    )),
                  SizedBox(height: 100),
          
                  
                ],
              ),
            )
            ),
        ),
      )
    );
  }
}