// lib/features/home/screens/home_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/home/presentation/widgets/banners_carousel.dart';
import 'package:fahem/features/home/presentation/widgets/welcome_header.dart';
import 'package:fahem/features/lessons/presentation/screens/subject_details_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/subject_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 3; 

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              // 1. الخلفية الفيروزية (مدمجة داخل السكرول لتفادي التداخل تماماً)
              Container(
                height: MediaQuery.of(context).size.height * 0.32, // ارتفاع مريح للبانر
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                ),
              ),

              // 2. المحتوى الأمامي (الكروت)
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // الترويسة والترحيب
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: HomeHeader(userName: 'أبانوب'),
                    ),
                    const SizedBox(height: 20),

                    // بنر الإعلانات
                    const BannersCarousel(),
                    const SizedBox(height: 25),

                    // 3. كارت لوحة الإنجاز الإجمالية (بإعدادات تمنع الـ Overflow)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('لوحة الإنجاز الإجمالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFEF6E5), borderRadius: BorderRadius.circular(10)),
                                child: const Text('65%', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 0.65,
                              backgroundColor: Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005F61)),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(Icons.emoji_events_rounded, color: Color(0xFFE6A100), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'أنجزت 65% من منهج الأسبوع! استمر يا بطل.',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // عنوان شبكة المواد الدراسية
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text('المواد الدراسية الحالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    ),
                    const SizedBox(height: 16),

                    // 4. شبكة المواد الدراسية (مربوطة بشاشة التفاصيل)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GridView.count(
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(), 
                        crossAxisCount: 2,
                        crossAxisSpacing: 16, 
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.15,
                        // 👈 تمت إزالة الـ const من القائمة لإضافة التوجيه الديناميكي
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()));
                            },
                            child: const SubjectCard(title: 'اللغة العربية', progress: 0.90, icon: Icons.menu_book_rounded),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()));
                            },
                            child: const SubjectCard(title: 'اللغة الانجليزية', progress: 0.50, icon: Icons.explicit_rounded),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()));
                            },
                            child: const SubjectCard(title: 'الرياضيات', progress: 0.75, icon: Icons.calculate_rounded),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()));
                            },
                            child: const SubjectCard(title: 'العلوم', progress: 0.40, icon: Icons.biotech_rounded),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()));
                            },
                            child: const SubjectCard(title: 'الدراسات الاجتماعية', progress: 0.50, icon: Icons.public_rounded),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 110), // مسافة البار السفلي
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}