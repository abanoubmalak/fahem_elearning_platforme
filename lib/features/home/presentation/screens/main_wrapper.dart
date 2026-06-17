// lib/features/home/presentation/screens/main_wrapper.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/courses/presentation/screens/courses.dart';
import 'package:fahem/features/home/presentation/screens/home.dart';
import 'package:fahem/features/performance/presentation/screens/performance_screen.dart';
import 'package:fahem/features/teachers/presentation/screens/contact_teachers_screen.dart';
import 'package:flutter/material.dart';
// قم بعمل import للشاشات الأربعة الخاصة بك هنا


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 3; // نبدأ من 3 لتكون "الرئيسية" هي الشاشة الافتراضية عند الفتح (أقصى اليمين)

  // قائمة الشاشات المرتبطة بأزرار التنقل (يجب أن تطابق ترتيب الأزرار بالأسفل)
  final List<Widget> _screens = const [
   // PerformanceScreen(), // 0. الأداء
    //TeachersScreen(),    // 1. تواصل مع مدرسك
    //MyCoursesScreen(), 
    //]
    PerformanceScreen(),  
    ContactTeachersScreen(),
    Courses(),
    HomeScreen(),  
             // 3. الرئيسية
         // 3. الرئيسية
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack يحفظ حالة كل شاشة (State) فلا تعيد التحميل من الصفر عند التنقل بين التبويبات
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      // هنا نضع كود لوحة التنقل المحدث والمريح بصرياً الذي استقررنا عليه
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textGrey,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo', 
                  fontWeight: FontWeight.bold, 
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo', 
                  fontSize: 11,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined, size: 26),
                    activeIcon: Icon(Icons.analytics, size: 26),
                    label: 'الأداء',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: 26),
                    activeIcon: Icon(Icons.chat_bubble_rounded, size: 26),
                    label: 'تواصل مع مدرسك',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.collections_bookmark_outlined, size: 26),
                    activeIcon: Icon(Icons.collections_bookmark_rounded, size: 26),
                    label: 'دوراتي',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined, size: 26),
                    activeIcon: Icon(Icons.home_rounded, size: 26),
                    label: 'الرئيسية',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}