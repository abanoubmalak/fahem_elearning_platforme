import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/login/presentation/screens/login.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});

@override
State<SignUpScreen> createState()=> _SignUpScreen();

}

class _SignUpScreen extends State<SignUpScreen> with SingleTickerProviderStateMixin{
  final _nameController=TextEditingController();
  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  final _confirmPasswordController=TextEditingController();


  bool _obscurePassword=true;
  bool _obscureConfirmPassword=true;


@override
Widget build(BuildContext context){
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Center(
              child:ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Image.asset("assets/images/logo.png",
                    width: 150,
                    height: 150 ,
                  ),
                ),
            ),
            SizedBox(height: 10,),
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
              const SizedBox(height: 30,),
              TextField(
                controller:_nameController,
                keyboardType: TextInputType.name,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                    hintText: 'الاسم الكامل',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold
                    ),
      
                    prefixIcon: Icon(Icons.person,size: 30,color: AppColors.primaryTeal,),
      
                    filled: true,
                    fillColor: Colors.white,
      
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
      
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColors.primaryTeal,width: 2)
      
                    ),
      
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: AppColors.primaryTeal,width: 3)
                    )
      
                ),
              ),
      
              SizedBox(height: 20,),
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
      
                  SizedBox(height: 20,),
      
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
      
                  SizedBox(height: 20,),  
      
                  TextField(
                      
                      controller:_confirmPasswordController,
                      obscureText:  _obscureConfirmPassword,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        
                        hintText: 'تأكيد كلمة المرور',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color:Colors.grey,
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold
                        ),
          
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: IconButton(
                            icon:Icon(_obscureConfirmPassword?Icons.visibility_off_rounded:Icons.visibility_rounded,size:30,color: AppColors.primaryTeal,),
                            onPressed: (){
                              setState(() {
                                _obscureConfirmPassword=!_obscureConfirmPassword;
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
      
                  SizedBox(height: 25,),
      
                  ElevatedButton(
                      onPressed: (){debugPrint('Email: ${_emailController.text}');},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)
                        ),
                        elevation: 0
                      ),
                      child: Text(
                        'إنشاء حساب',
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
                  
                  children: [
                    
                    TextButton(
                      onPressed:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>const LoginScreen())
                        );
                      },
                      child: const Text(
                        ' تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF269A9E),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      
                    ),
                    const Text(
                      'لديك حساب بالفعل؟',
                       style:  TextStyle(color: Colors.black, fontFamily: 'Cairo', fontSize: 14,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
      
      
      
      
          ],
        )
        
        ),
      )
    );
  }
}  