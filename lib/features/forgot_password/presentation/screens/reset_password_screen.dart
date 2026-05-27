
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/forgot_password/presentation/screens/reset_success_screen.dart';
import 'package:fahem/features/login/presentation/screens/login.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget{
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController=TextEditingController();

  final _passwordConfirmController=TextEditingController();

  bool _obscurePassword=true;

  bool _obscurePasswordConfirm=true;

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
                children: [
                  SizedBox(height: 20.0,),
              
                  Icon(Icons.lock_reset_rounded, size: 150, color: Color(0xFF269A9E)),
                
                    SizedBox(height: 30),
                
                    Text(
                      "إعادة تعيين كلمة المرور",
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGreyColor,
                        )
                    ),
                    SizedBox(height: 10,),
                    Text(
                      "أنشئ كلمة مرور جديدة وقوية", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color:AppColors.darkGreyColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                        fontSize: 16)
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
                      controller:_passwordConfirmController,
                      obscureText:  _obscurePasswordConfirm,
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
                            icon:Icon(_obscurePasswordConfirm?Icons.visibility_off_rounded:Icons.visibility_rounded,size:30,color: AppColors.primaryTeal,),
                            onPressed: (){
                              setState(() {
                                _obscurePasswordConfirm=!_obscurePasswordConfirm;
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
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context)=> const ResetSuccessScreen())
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
                  SizedBox(height: 25,),
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text(
                      "Cancel", 
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        )
                    )
                  ),
                  SizedBox(height: 50,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}