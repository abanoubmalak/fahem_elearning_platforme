// lib/features/admin/presentation/screens/admin_main_wrapper.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:fahem/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_financials_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_parents_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_students_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_teachers_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});

  @override
  State<AdminMainWrapper> createState() => _AdminMainWrapperState();
}

class _AdminMainWrapperState extends State<AdminMainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminTeachersManagementScreen(),
    const AdminStudentsManagementScreen(),
    const AdminParentsManagementScreen(), // 👈 القسم الجديد
    const AdminTreasuryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit()..listenToPlatformLive(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF005F61),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 10),
          elevation: 15,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'المعلمون'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'الطلاب'),
            BottomNavigationBarItem(icon: Icon(Icons.family_restroom_rounded), label: 'أولياء الأمور'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'المالية'),
          ],
        ),
      ),
    );
  }
}