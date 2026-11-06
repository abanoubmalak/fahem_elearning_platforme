
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class OtpBix extends StatelessWidget{
  OtpBix({super.key});

  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,

        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },

        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
            }
            if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },

        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,

          
          enabledBorder: OutlineInputBorder(
            borderRadius:  BorderRadius.circular(10.0),
            borderSide: BorderSide(color: AppColors.primaryTeal,width: 2)
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: AppColors.primaryTeal,width: 3)
          )
        )  
      ),
    );
  }
}