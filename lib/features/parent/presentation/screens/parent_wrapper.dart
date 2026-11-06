import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:fahem/features/parent/presentation/screens/parent_home_screen.dart';
import 'package:fahem/features/parent/presentation/screens/parent_profile_screen.dart';
import 'package:fahem/features/parent/presentation/screens/payment_checkout_screen.dart';
import 'package:fahem/features/parent/presentation/screens/link_child_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentWrapper extends StatefulWidget {
  const ParentWrapper({super.key});

  @override
  State<ParentWrapper> createState() => _ParentWrapperState();
}

class _ParentWrapperState extends State<ParentWrapper> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => ParentCubit(),
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const ParentHomeScreen(),
              LinkChildScreen(onTabSwitch: _switchTab),        
              PaymentCheckoutScreen(packageAmount: 150.0, onTabSwitch: _switchTab), 
              const ParentProfileScreen(),    
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _switchTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF005F61), 
              unselectedItemColor: Colors.grey[400],
              selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 30), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.person_add_rounded, size: 30), label: 'إضافة طالب'),
                BottomNavigationBarItem(icon: Icon(Icons.payments_rounded, size: 30), label: 'الدفع'), 
                BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded, size: 30), label: 'البروفيل'), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}