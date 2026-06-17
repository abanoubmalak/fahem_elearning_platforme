// lib/features/lessons/screens/video_player_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String lessonTitle;

  const VideoPlayerScreen({
    super.key, 
    required this.lessonTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ارتفاع مساحة الفيديو بدقة (38% من ارتفاع الشاشة لترك مساحة كافية للتحكم)
    final double videoHeight = _isFullscreen 
        ? MediaQuery.of(context).size.height 
        : MediaQuery.of(context).size.height * 0.38;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. مشغل الفيديو الأساسي ====================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              left: 0,
              right: 0,
              height: videoHeight,
              child: Container(
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: _isInitialized
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller.value.size.width,
                                height: _controller.value.size.height,
                                child: VideoPlayer(_controller),
                              ),
                            )
                          : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ),
                    
                    // طبقة تظليل تدرجي داكنة أسفل وأعلى الفيديو لإبراز الأزرار البيضاء بشكل واضح جداً
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha((0.4 * 255).toInt()),
                              Colors.transparent,
                              Colors.black.withAlpha((0.5 * 255).toInt()),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // زر التشغيل/الإيقاف العائم والمطور في منتصف الفيديو
                    if (_isInitialized)
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.value.isPlaying ? _controller.pause() : _controller.play();
                            });
                          },
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withAlpha((0.25 * 255).toInt()),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: Icon(
                                _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: const Color(0xFF0D2C2D),
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // أزرار التحكم العلوية (الرجوع والإعدادات)
                    if (!_isFullscreen) ...[
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withAlpha((0.3 * 255).toInt()),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withAlpha((0.3 * 255).toInt()),
                          child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ==================== 2. النصف السفلي: الكارت المنبثق الدائري المحدث موقعه ====================
            if (!_isFullscreen)
              Positioned(
                // تم تعديل نقطة البداية لتبدأ عند 36% بدقة، مما يترك مساحة كافية تماماً لشريط التقدم بالأعلى
                top: MediaQuery.of(context).size.height * 0.36,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صف عنوان الدرس والـ Bookmark والـ Lesson 1 المماثل لـ لقطة الشاشة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.bookmark_border_rounded, color: AppColors.textMain, size: 26),
                          //const Spacer(),
                          const SizedBox(width: 5,),
                          Text(
                            widget.lessonTitle,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                              
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // المتن العلمي والشروح الموجزة المعتمدة عندك
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStructureSlideCard(
                                originalText: 'المتن الأصلي: يتكون الجدول الدوري من 18 مجموعة رأسية و7 دورات أفقية.',
                                summaryText: 'الشرح الموجز: التقسيم الهيكلي للعناصر يعتمد على مستويات الطاقة الفرعية وعدد الإلكترونات الخارجية لتسهيل دراسة تفاعلاتها.',
                              ),
                              _buildStructureSlideCard(
                                originalText: 'المتن الأصلي: عناصر المجموعات (1A, 2A) تمثل الفئة S وتتميز بخصائص فلزية قوية.',
                                summaryText: 'الشرح الموجز: تفقد هذه العناصر إلكترونات التكافؤ بسهولة لتكوين روابط أيونية مستقرة مع الفئات الأخرى.',
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ==================== 3. عناصر التحكم السفلية المحدثة (فوق الكارت بوضوح تام) ====================
            if (_isInitialized)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                // تم رفع الإحداثيات برمجياً لتستقر فوق منحنى الكارت الأبيض تماماً وتظهر بالكامل للعين
                top: _isFullscreen 
                    ? MediaQuery.of(context).size.height - 60 
                    : (MediaQuery.of(context).size.height * 0.36) - 50, 
                left: 0,
                right: 0,
                height: 45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // أ) زر تكبير الشاشة (أقصى اليمين في واجهات الـ RTL، واضح وكبير جداً)
                      GestureDetector(
                        onTap: _toggleFullscreen,
                        child: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 32, // تكبير الحجم لرؤية فائقة الوضوح وضغط مريح
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // ب) شريط التقدم النحيف والمطابق لتصميمك بلون أبيض صافي
                      Expanded(
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.white, 
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ==================== 4. زر التقييم الذكي المنحني في الأسفل ====================
            if (!_isFullscreen)
              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 12,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6A100),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ابدأ الاختبار الآن لقياس فهمك',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureSlideCard({
    required String originalText,
    required String summaryText,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: AppColors.commonShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            originalText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF005F61),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(color: Color(0xFFEDF2F7), thickness: 1),
          ),
          Text(
            summaryText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textMain,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}