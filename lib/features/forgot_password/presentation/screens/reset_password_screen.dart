
// import 'package:fahem/core/constants/colors.dart';
// import 'package:fahem/features/forgot_password/presentation/screens/reset_success_screen.dart';
// import 'package:flutter/material.dart';

// class ResetPasswordScreen extends StatefulWidget{
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _passwordController=TextEditingController();

//   final _passwordConfirmController=TextEditingController();

//   bool _obscurePassword=true;

//   bool _obscurePasswordConfirm=true;

//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
//               child: Column(
//                 children: [
//                   SizedBox(height: 20.0,),
              
//                   Icon(Icons.lock_reset_rounded, size: 150, color: Color(0xFF269A9E)),
                
//                     SizedBox(height: 30),
                
//                     Text(
//                       "إعادة تعيين كلمة المرور",
//                       style: TextStyle(
//                         fontFamily: "Cairo",
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                         color: AppColors.darkGreyColor,
//                         )
//                     ),
//                     SizedBox(height: 10,),
//                     Text(
//                       "أنشئ كلمة مرور جديدة وقوية", 
//                       textAlign: TextAlign.center, 
//                       style: TextStyle(color:AppColors.darkGreyColor,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: "Cairo",
//                         fontSize: 16)
//                       ),
//                     SizedBox(height: 20,),
                      
//                     TextField(
//                       controller:_passwordController,
//                       obscureText:  _obscurePassword,
//                       keyboardType: TextInputType.emailAddress,
//                       textAlign: TextAlign.right,
//                       decoration: InputDecoration(
                        
//                         hintText: 'كلمة المرور',
//                         hintStyle: const TextStyle(
//                           fontSize: 15,
//                           color:Colors.grey,
//                           fontFamily: "Cairo",
//                           fontWeight: FontWeight.bold
//                         ),
                      
//                         suffixIcon: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: IconButton(
//                             icon:Icon(_obscurePassword?Icons.visibility_off_rounded:Icons.visibility_rounded,size:30,color: AppColors.primaryTeal,),
//                             onPressed: (){
//                               setState(() {
//                                 _obscurePassword=!_obscurePassword;
//                               });
//                             },
//                           ),
//                         ),
                        
//                         prefixIcon: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Icon(Icons.lock_rounded,size:30,color:AppColors.primaryTeal),
//                         ),
                      
//                         filled:true,
//                         fillColor: Colors.white,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                      
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius:  BorderRadius.circular(30.0),
//                           borderSide: BorderSide(color: AppColors.primaryTeal,width: 2),
//                         ),
                      
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                           borderSide: BorderSide(color: AppColors.primaryTeal,width: 3)
//                           )
//                         ),
//                       ),
                    
//                     SizedBox(height: 20,),  
                    
//                     TextField(   
//                       controller:_passwordConfirmController,
//                       obscureText:  _obscurePasswordConfirm,
//                       keyboardType: TextInputType.emailAddress,
//                       textAlign: TextAlign.right,
//                       decoration: InputDecoration(
                        
//                         hintText: 'تأكيد كلمة المرور',
//                         hintStyle: const TextStyle(
//                           fontSize: 15,
//                           color:Colors.grey,
//                           fontFamily: "Cairo",
//                           fontWeight: FontWeight.bold
//                         ),
                      
//                         suffixIcon: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: IconButton(
//                             icon:Icon(_obscurePasswordConfirm?Icons.visibility_off_rounded:Icons.visibility_rounded,size:30,color: AppColors.primaryTeal,),
//                             onPressed: (){
//                               setState(() {
//                                 _obscurePasswordConfirm=!_obscurePasswordConfirm;
//                               });
//                             },
//                           ),
//                         ),
//                         prefixIcon: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Icon(Icons.lock_rounded,size:30,color:AppColors.primaryTeal),
//                         ),
                      
//                         filled:true,
//                         fillColor: Colors.white,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                      
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius:  BorderRadius.circular(30.0),
//                           borderSide: BorderSide(color: AppColors.primaryTeal,width: 2),
//                         ),
                      
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                           borderSide: BorderSide(color: AppColors.primaryTeal,width: 3)
//                         )
//                       ),
//                   ),
//                   SizedBox(height: 20,),
//                   ElevatedButton(
//                     onPressed: (){
//                       Navigator.push(
//                         context, 
//                         MaterialPageRoute(builder: (context)=> const ResetSuccessScreen())
//                         );
//                       },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryTeal,
//                       minimumSize: const Size(double.infinity, 65),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0)
//                       ),
//                       elevation: 0
//                     ),
//                     child: Text(
//                       "متابعة",
//                       style: TextStyle(
//                       fontFamily: 'Cairo',
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 25,),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context), 
//                     child: Text(
//                       "Cancel", 
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 25,
//                         )
//                     )
//                   ),
//                   SizedBox(height: 50,)
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_state.dart';
import 'package:fahem/features/forgot_password/presentation/screens/reset_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthResetPasswordSuccess) {
            // فتح شاشة النجاح النهائية فوراً 🎉
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResetSuccessScreen()));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.redAccent));
          }
        },
        builder: (context, state) {
          bool isLoading = state is AuthLoading;

          return Center(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20.0),
                        const Icon(Icons.lock_reset_rounded, size: 150, color: Color(0xFF269A9E)),
                        const SizedBox(height: 30),
                        const Text("إعادة تعيين كلمة المرور", style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.darkGreyColor)),
                        const SizedBox(height: 10),
                        const Text("أنشئ كلمة مرور جديدة وقوية ومطابقة", textAlign: TextAlign.center, style: TextStyle(color: AppColors.darkGreyColor, fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 16)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController, obscureText: _obscurePassword,
                          textAlign: TextAlign.right,
                          validator: (val) => (val == null || val.length < 6) ? 'كلمة المرور يجب ألا تقل عن 6 أحرف' : null,
                          decoration: InputDecoration(
                            hintText: 'كلمة المرور الجديدة',
                            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                            suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 30, color: AppColors.primaryTeal), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                            prefixIcon: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.lock_rounded, size: 30, color: AppColors.primaryTeal)),
                            filled: true, fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3))
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordConfirmController, obscureText: _obscurePasswordConfirm,
                          textAlign: TextAlign.right,
                          validator: (val) => (val != _passwordController.text) ? 'كلمات المرور غير متطابقة ❌' : null,
                          decoration: InputDecoration(
                            hintText: 'تأكيد كلمة المرور',
                            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                            suffixIcon: IconButton(icon: Icon(_obscurePasswordConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 30, color: AppColors.primaryTeal), onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm)),
                            prefixIcon: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.lock_rounded, size: 30, color: AppColors.primaryTeal)),
                            filled: true, fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 3))
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              cubit.resetUserPassword(_passwordController.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), elevation: 0),
                          child: isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text("تأكيد وحفظ", style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 25),
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo'))),
                        const SizedBox(height: 50,)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}