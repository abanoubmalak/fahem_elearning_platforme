// lib/features/parent/presentation/screens/parent_wrapper.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/parent/presentation/screens/parent_home_screen.dart';
import 'package:fahem/features/parent/presentation/screens/parent_profile_screen.dart';
import 'package:fahem/features/parent/presentation/screens/payment_checkout_screen.dart';
import 'package:fahem/features/parent/presentation/screens/link_child_screen.dart'; // تأكد من استيراد الشاشة
import 'package:flutter/material.dart';

class ParentWrapper extends StatefulWidget {
  const ParentWrapper({super.key});

  @override
  State<ParentWrapper> createState() => _ParentWrapperState();
}

class _ParentWrapperState extends State<ParentWrapper> {
  int _currentIndex = 0;

  // قائمة الشاشات المرتبة حسب طلبك
  final List<Widget> _pages = [
    const ParentHomeScreen(),
    const LinkChildScreen(),        // شاشة إضافة طالب
    const ParentProfileScreen(),    // البروفيل
    const PaymentCheckoutScreen(packageAmount: 100,children: ["Abanoub","Mian"]), // الدفع (يمكنك تمرير اسم الابن لاحقاً)
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // IndexedStack يحافظ على حالة الشاشات (State) ولا يعيد بناءها عند التنقل
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF005F61), // اللون الفيروزي المعتمد
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded,size: 30), 
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_add_rounded,size: 30), 
                label: 'إضافة طالب',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_rounded,size: 30,), 
                label: 'البروفيل',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payments_rounded,size: 30), 
                label: 'الدفع',
              ),
            ],
          ),
        ),
      ),
    );
  }
}