// lib/features/teacher/presentation/screens/manage_sections/teacher_lessons_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'lesson_content_hub_screen.dart'; // استيراد الشاشة المجمعة والمركزية الجديدة

class TeacherLessonsScreen extends StatefulWidget {
  final String unitName;
  final String stageName;
  const TeacherLessonsScreen({super.key, required this.unitName, required this.stageName});

  @override
  State<TeacherLessonsScreen> createState() => _TeacherLessonsScreenState();
}

class _TeacherLessonsScreenState extends State<TeacherLessonsScreen> {
  // قائمة الدروس التجريبية داخل الوحدة المحددة (قابلة للتعديل والمزامنة الحية)
  final List<String> _lessons = [
    'الدرس الأول: التعبير الرمزي عن الدالة',
    'الدرس الثاني: دوال كثيرات الحدود',
    'الدرس الثالث: دراسة بعض الدوال الخاصة',
  ];

  // دالة إضافة درس جديد ديناميكياً وحركياً لحساب حالة الواجهة
  void _openAddLessonBottomSheet() {
    final TextEditingController lessonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(context).viewInsets.bottom + 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إضافة درس جديد للوحدة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: lessonController,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'عنوان أو اسم الدرس الجديد',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (lessonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('من فضلك أدخل اسم الدرس أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }

                    setState(() {
                      _lessons.add(lessonController.text.trim());
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة الدرس الجديد للوحدة بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.primary),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F61), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), 
                    elevation: 0,
                  ),
                  child: const Text('إدراج الدرس الآن', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddLessonBottomSheet,
        backgroundColor: const Color(0xFFE6A100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_to_photos_rounded, color: Colors.white, size: 18),
        label: const Text('إضافة درس للوحدة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. قائمة كروت الدروس التفاعلية (في الخلفية أولاً) ====================
            // 💎 نقلنا محتوى اللستة ليكون أول عنصر في الـ Stack ليسمح لما بعده بالظهور والضغط 💎
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _lessons.isEmpty
                    ? const Center(child: Text('لا توجد دروس مضافة في هذه الوحدة حالياً.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _lessons.length,
                        padding: EdgeInsets.fromLTRB(0, headerHeight + 15, 0, 80),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.01 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 3))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: const CircleAvatar(backgroundColor: Color(0xFFFEF6E5), child: Icon(Icons.menu_book_rounded, color: Color(0xFFE6A100), size: 18)),
                              title: Text(
                                _lessons[index], 
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textMain),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.settings_suggest_rounded, size: 18, color: Color(0xFF005F61)),
                              onTap: () {
                                // 💥 التوجيه الفخم والمعدل لشاشة الـ Hub المجمعة والمؤمنة بالكامل 💥
                                Navigator.pushNamed(context, Routes.LessonContentHubScreen);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),

            // ==================== 2. البانر العلوي الموحد (في المقدمة آخراً) ====================
            // 💎 تم وضعه آخراً ليكون طافياً فوق محاذاة الاسكرول وتصبح أزراره نشطة وقابلة للمس 💎
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-20,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              onPressed: () => Navigator.pushNamed(context, Routes.TeacherUnitsScreen), // سيعمل كالسحر فوراً وبدون أي عوائق!
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(widget.unitName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(widget.stageName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
}