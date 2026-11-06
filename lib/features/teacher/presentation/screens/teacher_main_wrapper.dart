import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_profits_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_questions_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_statistics_screen.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_cubit.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherMainWrapper extends StatefulWidget {
  const TeacherMainWrapper({super.key});

  @override
  State<TeacherMainWrapper> createState() => _TeacherMainWrapperState();
}

class _TeacherMainWrapperState extends State<TeacherMainWrapper> {
  int _currentTabIndex = 0;

  final List<Widget> _tabs = [
    const TeacherSubjectsTab(),
    const TeacherQuestionsScreen(),
    const TeacherStatisticsScreen(),
    const TeacherFinancialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => TeacherCubit()..fetchTeacherDashboard(),
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          
          body: IndexedStack(
            index: _currentTabIndex,
            children: _tabs,
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.04 * 255).toInt()),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF005F61),
              unselectedItemColor: Colors.grey[400],
              selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_stories_outlined, size: 30),
                  activeIcon: Icon(Icons.auto_stories_rounded, size: 30),
                  label: 'موادي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 30),
                  activeIcon: Icon(Icons.chat_bubble_rounded, size: 30),
                  label: 'الأسئلة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined, size: 30),
                  activeIcon: Icon(Icons.analytics_rounded, size: 30),
                  label: 'الإحصائيات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined, size: 30),
                  activeIcon: Icon(Icons.account_balance_wallet_rounded, size: 30),
                  label: 'الأرباح',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}