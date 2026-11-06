import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: const Icon(Icons.person, color: AppColors.darkGreyColor,),
                onPressed: (){
                  Navigator.pushNamed(
                    context, 
                    Routes.ProfileScreen, 
                    arguments: context.read<StudentCubit>(), // إرسال الكوبيت الحالي عبر الراوتر
                  );
                }
                
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'أهلاً، $userName!',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
   
      ],
    );
  }
}