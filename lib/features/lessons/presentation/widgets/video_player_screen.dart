// lib/features/lessons/screens/video_player_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 إضافة الفايربيز
import 'package:firebase_auth/firebase_auth.dart'; // 👈 إضافة الأوث
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/lessons/presentation/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String lessonTitle;
  final String videoUrl; 
  final List<dynamic> questions; 
  final String subjectId; 
  final String studentTerm;

  const VideoPlayerScreen({
    super.key, 
    required this.lessonTitle,
    required this.videoUrl, 
    required this.questions, 
    required this.subjectId,
    required this.studentTerm,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller; // 👈 جعل المتغير اختياري لتجنب استخدامه قبل التهيئة
  bool _isInitialized = false;
  bool _isFullscreen = false;
  bool _hasVideoError = false; // 👈 علم للإشارة إلى وجود خطأ أو عدم توفر الفيديو

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // 1️⃣ شرط الحماية: التحقق من صحة الرابط قبل التمرير للمكتبة لمنع التجمد والسواد
    if (widget.videoUrl.trim().isEmpty) {
      setState(() {
        _hasVideoError = true;
        _isInitialized = false;
      });
      return;
    }

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() { 
              _isInitialized = true; 
              _hasVideoError = false;
            });
          }
        }).catchError((error) {
          debugPrint('❌ خطأ في تهيئة الفيديو: $error');
          if (mounted) {
            setState(() {
              _hasVideoError = true;
              _isInitialized = false;
            });
          }
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
        });
      }
    }
  }

  // 💎 دالة تحديث حالة المشاهدة في الفايربيز
  Future<void> _markVideoAsWatched() async {
    try {
      final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (studentId.isEmpty) return;

      await FirebaseFirestore.instance
          .collection('student_progress')
          .doc('${studentId}_${widget.subjectId}_${widget.lessonTitle.replaceAll(" ", "_")}')
          .set({
        'studentId': studentId,
        'subjectId': widget.subjectId,
        'lessonTitle': widget.lessonTitle,
        'isVideoWatched': true, // 👈 تحديث أن الفيديو اتشاف
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ خطأ في حفظ المشاهدة: $e');
    }
  }

  void _toggleFullscreen() {
    setState(() { _isFullscreen = !_isFullscreen; });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller?.dispose(); // 👈 الاستدعاء الآمن للمشغل عند تدمير الصفحة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double videoHeight = _isFullscreen ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.38;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0, left: 0, right: 0, height: videoHeight,
              child: Container(
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: _hasVideoError
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_camera_back_rounded, color: Colors.grey, size: 42),
                                  SizedBox(height: 8),
                                  Text('فيديو الشرح غير متاح حالياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            )
                          : (_isInitialized && _controller != null)
                              ? FittedBox(fit: BoxFit.cover, child: SizedBox(width: _controller!.value.size.width, height: _controller!.value.size.height, child: VideoPlayer(_controller!)))
                              : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.black.withAlpha((0.4 * 255).toInt()), Colors.transparent, Colors.black.withAlpha((0.5 * 255).toInt())],
                          ),
                        ),
                      ),
                    ),
                    if (_isInitialized && _controller != null && !_hasVideoError)
                      Center(
                        child: GestureDetector(
                          onTap: () { setState(() { _controller!.value.isPlaying ? _controller!.pause() : _controller!.play(); }); },
                          child: CircleAvatar(
                            radius: 32, backgroundColor: Colors.white.withAlpha((0.25 * 255).toInt()),
                            child: CircleAvatar(radius: 26, backgroundColor: Colors.white, child: Icon(_controller!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: const Color(0xFF0D2C2D), size: 32)),
                          ),
                        ),
                      ),
                    if (!_isFullscreen) ...[
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10, right: 20,
                        child: CircleAvatar(backgroundColor: Colors.black.withAlpha((0.3 * 255).toInt()), child: IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context))),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10, left: 20,
                        child: GestureDetector(onTap: _toggleFullscreen, child: CircleAvatar(backgroundColor: Colors.black.withAlpha((0.3 * 255).toInt()), child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24))),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!_isFullscreen)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.36, left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF004D4F).withAlpha((0.08 * 255).toInt()), shape: BoxShape.circle),
                        child: const Icon(Icons.local_library_rounded, color: Color(0xFF005F61), size: 38),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.lessonTitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                      const SizedBox(height: 8),
                      const Text('شاهدت الفيديو؟ جاهز الآن لتقييم مستوى فهمك واستيعابك للدرس؟', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5, color: Colors.grey)),
                      const Spacer(), 
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // 💎 المنطق الجديد: تسجيل المشاهدة ثم الانتقال للاختبار
                            await _markVideoAsWatched(); 
                            if (!mounted) return;
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  lessonTitle: widget.lessonTitle,
                                  questions: widget.questions,
                                  subjectId: widget.subjectId,
                                  studentTerm: widget.studentTerm,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                          icon: const Icon(Icons.play_lesson_rounded, color: Colors.white),
                          label: const Text('ابدأ الاختبار الآن لقياس فهمك', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}