// lib/features/home/presentation/widgets/banners_carousel.dart
import 'dart:async';
import 'package:fahem/core/constants/colors.dart'; // المسار الصحيح تماماً كما في جهازك
import 'package:flutter/material.dart';

class BannersCarousel extends StatefulWidget {
  const BannersCarousel({super.key});

  @override
  State<BannersCarousel> createState() => _BannersCarouselState();
}

class _BannersCarouselState extends State<BannersCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // القائمة تحتوي على مسارات الصور المصممة والمطابقة للـ Explorer عندك
  final List<String> _bannerImages = [
    'assets/images/banner1.png', // تغيير png إلى jpg
    'assets/images/banner2.png',
    'assets/images/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // تقليب البنرات تلقائياً كل 4 ثوانٍ
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140, // ارتفاع مثالي ومناسب جداً لأبعاد البنرات العريضة
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // حل مشكلة الـ withOpacity واستبدالها بالطريقة الحديثة المتوافقة مع تحديثات فلاتر 2026
                  color: AppColors.primary.withAlpha((0.05 * 255).toInt()), 
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.fill, // يضمن تمدد الصورة لملء المساحة كاملة
                    errorBuilder: (context, error, stackTrace) {
                      List<IconData> icons = [
                        Icons.lightbulb_outline_rounded,
                        Icons.assignment_turned_in_outlined,
                        Icons.chat_bubble_outline_rounded
                      ];
                      return Center(
                        child: Icon(
                          icons[index], 
                          size: 50, 
                          color: AppColors.primary.withAlpha((0.6 * 255).toInt()),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // نقاط المؤشر السفلي المتفاعلة (Dots Indicator)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}