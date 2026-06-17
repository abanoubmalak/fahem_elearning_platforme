// lib/features/teachers/presentation/screens/contact_teachers_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

class ContactTeachersScreen extends StatefulWidget {
  const ContactTeachersScreen({super.key});

  @override
  State<ContactTeachersScreen> createState() => _ContactTeachersScreenState();
}

class _ContactTeachersScreenState extends State<ContactTeachersScreen> {
  // قائمة المدرسين
  final List<Map<String, dynamic>> _teachers = [
    {
      'name': 'أ. محمد أحمد',
      'subject': 'اللغة العربية',
      'icon': Icons.menu_book_rounded,
      'isOnline': true,
      'avatarColor': const Color(0xFFEDF7F7),
    },
    {
      'name': 'أ. سارة جون',
      'subject': 'اللغة الإنجليزية',
      'icon': Icons.g_translate_rounded,
      'isOnline': true,
      'avatarColor': const Color(0xFFFEF6E5),
    },
    {
      'name': 'أ. رأفت حكيم',
      'subject': 'الرياضيات',
      'icon': Icons.calculate_outlined,
      'isOnline': false,
      'avatarColor': const Color(0xFFF1F5F9),
    },
    {
      'name': 'أ. ميرفت علي',
      'subject': 'العلوم',
      'icon': Icons.biotech_outlined,
      'isOnline': true,
      'avatarColor': const Color(0xFFEAFAF1),
    },
    {
      'name': 'أ. خالد محمود',
      'subject': 'الدراسات الاجتماعية',
      'icon': Icons.public_rounded,
      'isOnline': false,
      'avatarColor': const Color(0xFFFFEAEA),
    },
  ];

  void _startChatWithTeacher(String teacherName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري فتح غرفة المحادثة الآمنة مع $teacherName...', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF005F61), // تم تعديله للون الفيروزي الأساسي
      ),
    );

  Navigator.pushNamed(context, Routes.ChatScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // توجيه المحتوى من اليمين لليسار
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 1. الترويسة العلوية باستخدام AppBar ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 100, // مساحة مريحة لاستيعاب العنوان والوصف
          automaticallyImplyLeading: false, // لعدم ظهور زر الرجوع إذا كانت في الـ Bottom Nav Bar
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'تواصل مع معلمك',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'اسأل معلم المادة مباشرة عن النقاط التي تقف أمامك',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white.withAlpha((0.7 * 255).toInt())),
              ),
            ],
          ),
        ),

        // ==================== 2. قائمة المدرسين (بدون Stack لتفادي التداخل) ====================
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _teachers.length,
          // بادينج من جميع الاتجاهات مع مسافة سفلية 110 لحماية الكروت من شريط التنقل
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0).copyWith(bottom: 110),
          itemBuilder: (context, index) {
            final teacher = _teachers[index];
            return _buildTeacherCard(teacher);
          },
        ),
      ),
    );
  }

  // ويدجت بناء كارت المدرس التفاعلي
  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final bool isOnline = teacher['isOnline'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.withAlpha((0.06 * 255).toInt())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أ) الصورة الرمزية للمدرس
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: teacher['avatarColor'],
                child: Icon(teacher['icon'], color: const Color(0xFF005F61), size: 26),
              ),
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF2ECC71) : Colors.grey[400],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),

          // ب) تفاصيل المدرس (محمية بـ Expanded لمنع Overflow)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher['name'],
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    teacher['subject'],
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ج) زر المحادثة
          ElevatedButton.icon(
            onPressed: () => _startChatWithTeacher(teacher['name']),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.white),
            label: const Text(
              'مراسلة',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE6A100), // اللون الذهبي
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}