// lib/features/teacher/presentation/screens/manage_sections/teacher_units_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'teacher_lessons_screen.dart';

class TeacherUnitsScreen extends StatefulWidget {
  final String stageName;
  const TeacherUnitsScreen({super.key, required this.stageName});

  @override
  State<TeacherUnitsScreen> createState() => _TeacherUnitsScreenState();
}

class _TeacherUnitsScreenState extends State<TeacherUnitsScreen> {
  // قائمة الوحدات الدراسية (تم إزالة final لتسمح بالتعديل البرمجي الحركي)
  final List<String> _units = [
    'الوحدة الأولى: العلاقات والدوال',
    'الوحدة الثانية: النسب والتناسب',
    'الوحدة الثالثة: الإحصاء والاحتمالات',
  ];

  // دالة إضافة وحدة جديدة ديناميكياً وتحديث حالة الشاشة
  void _openAddUnitBottomSheet() {
    final TextEditingController unitController = TextEditingController();

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
                'إضافة وحدة دراسية جديدة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: unitController,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'عنوان أو اسم الوحدة المقررة',
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
                    if (unitController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('من فضلك أدخل اسم الوحدة أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }

                    setState(() {
                      _units.add(unitController.text.trim());
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة الوحدة الجديدة للمنهج بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.primary),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F61), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), 
                    elevation: 0,
                  ),
                  child: const Text('إدراج الوحدة الآن', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
        onPressed: _openAddUnitBottomSheet,
        backgroundColor: const Color(0xFFE6A100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        label: const Text('إضافة وحدة جديدة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. قائمة الوحدات (في الخلفية أولاً) ====================
            // 💎 تم نقل محاذاة اللستة لتكون أول طبقة في الـ Stack 💎
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _units.isEmpty
                    ? const Center(child: Text('لا توجد وحدات دراسية مضافة حالياً.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _units.length,
                        padding: EdgeInsets.fromLTRB(0, headerHeight + 15, 0, 80),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.01 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: const CircleAvatar(backgroundColor: Color(0xFFEDF7F7), child: Icon(Icons.folder_open_rounded, color: Color(0xFF005F61), size: 20)),
                              title: Text(_units[index], style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                              onTap: () {
                                Navigator.pushNamed(context, Routes.TeacherLessonsScreen);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),

            // ==================== 2. البانر العلوي الموحد (في المقدمة آخراً) ====================
            // 💎 تم وضعه آخراً لكي يطفو فوق عناصر الاسكرول وتصبح أزراره نشطة وقابلة للمس 💎
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
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              onPressed: () => Navigator.pushNamed(context, Routes.TeacherMainWrapper), // سيعمل بكفاءة وسلاسة الآن
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(widget.stageName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const Text('قائمة الوحدات المقررة في المنهج', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)),
                                  
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