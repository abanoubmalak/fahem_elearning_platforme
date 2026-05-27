import "package:fahem/core/constants/colors.dart";
import "package:fahem/features/forgot_password/presentation/screens/forgot_password_screen.dart";
import "package:fahem/features/sign_up/presentation/screens/sign_up.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState()=>_LoginScreen();
}

class _LoginScreen extends State<LoginScreen>with SingleTickerProviderStateMixin{


  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: Image.asset("assets/images/logo.png",
                      width: 150,
                      height: 150 ,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(
                    'مش بس حافظ.. أنت فاهم',
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:AppColors.darkGreyColor,
                      wordSpacing: 0.5
        
                    ),
                  ),  
                  SizedBox(height: 60,),
                  TextField(
                    controller:_emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
        
                    decoration: InputDecoration(
                      hintText: 'البريد الإلكتروني ',
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
        
                  SizedBox(height: 30,),
        
                  TextField(
                    
                    controller:_passwordController,
                    obscureText:  _obscurePassword,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      
                      hintText: 'كلمة المرور',
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color:Colors.grey,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold
                      ),
        
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: IconButton(
                          icon:Icon(_obscurePassword?Icons.visibility_off_rounded:Icons.visibility_rounded,size:30,color: AppColors.primaryTeal,),
                          onPressed: (){
                            setState(() {
                              _obscurePassword=!_obscurePassword;
                            });
                          },
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.lock_rounded,size:30,color:AppColors.primaryTeal),
                      ),
        
                      filled:true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        
                      enabledBorder: OutlineInputBorder(
                        borderRadius:  BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: AppColors.primaryTeal,width: 2),
                      ),
        
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: AppColors.primaryTeal,width: 3)
                      )
                    ),
                  ),
        
                  SizedBox(height: 35,),
        
                  ElevatedButton(
                    onPressed: (){
                      
                      
                      
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
                      'تسجيل الدخول',
                      style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                      ),
                    ),
        
                    const SizedBox(height: 10,),
                    
                    TextButton(
                      onPressed: (){
                        debugPrint("Forget Password Screen");
                      }, 
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context)=>const ForgotPasswordScreen())
                          );
                        },
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.black, // لون رمادي فاتح للرابط
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                          ),
                      )
                      ),
        
                    const SizedBox(height: 10),
                    // Row لترتيب الأيقونات في القاع
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // محاذاة لليسار
                      children: [
                        // 8. أيقونة الشات الدائرية (chat bubble)
                        IconButton(
                          icon: Icon(Icons.forum,color: AppColors.primaryTeal,size: 35,),
                          onPressed: () {
                            // سيتم وضع وظيفة الشات هنا مستقبلاً
                            //chat on whatsapp,contact screen, AI boot>>>>>>>>><<<<<<<<<<
                          },
                        ),
                      ],
                    ),
        
                    const SizedBox(height: 10,),
        
                    Text.rich(
                      TextSpan(
                        text: 'ليس لديك حساب؟ ',
                        style: const TextStyle(color: Colors.black, fontFamily: 'Cairo', fontSize: 16,fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: 'إنشاء حساب',
                            style: const TextStyle(
                              color: AppColors.primaryTeal, // اللون الفيروزي للرابط
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 18
        
                            ),
                            // سيتم إضافة وظيفة الانتقال لشاشة إنشاء حساب هنا مستقبلاً
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder:  (context)=>const SignUpScreen())
                              
                              );
                            },
                          ),
                        ],
                      ),
                      ),
        
                  SizedBox(height: 30,)
                ],
                ),
            ),
          )
          
          
          ),
      )
        
        

      
    );
  }
}