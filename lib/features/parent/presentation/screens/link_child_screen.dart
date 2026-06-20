// lib/features/parent/presentation/screens/link_child_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 استيراد الفايرستور للاستعلام الحي
import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LinkChildScreen extends StatefulWidget {
  final Function(int) onTabSwitch; // للانتقال السلس

  const LinkChildScreen({super.key, required this.onTabSwitch});

  @override
  State<LinkChildScreen> createState() => _LinkChildScreenState();
}

class _LinkChildScreenState extends State<LinkChildScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isSearching = false;
  bool _childFound = false;

  // متغيرات حفظ بيانات الطالب الحقيقي العائد من السيرفر
  String _foundStudentName = '';
  String _foundStudentStage = '';

  // 💎 دالة البحث الحي الحقيقي عن الطالب في قاعدة البيانات باستخدام الكود
  void _searchForChild() async {
    final String enteredCode = _codeController.text.trim();
    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('من فضلك أدخل كود الربط أولاً', style: TextStyle(fontFamily: 'Cairo')), 
          backgroundColor: Colors.redAccent
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _childFound = false;
    });
    FocusScope.of(context).unfocus(); 

    try {
      // الاستعلام عن كود الطالب حياً من كوليكشن students الموثق بالـ Seeder
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('students')
          .where('linkCode', isEqualTo: enteredCode)
          .get();

      if (studentQuery.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('كود الربط غير صحيح أو غير مسجل في المنظومة ❌', style: TextStyle(fontFamily: 'Cairo')), 
              backgroundColor: Colors.redAccent
            ),
          );
          setState(() => _isSearching = false);
        }
        return;
      }

      final studentDoc = studentQuery.docs.first;
      final studentData = studentDoc.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _foundStudentName = studentData['name'] ?? 'طالب فاهم';
          _foundStudentStage = studentData['stage'] ?? 'الصف الأول الإعدادي';
          _isSearching = false;
          _childFound = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء البحث: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
        );
        setState(() => _isSearching = false);
      }
    }
  }

  // 💎 دالة تأكيد الربط السحابي والانتقال الآمن للرئيسية
  void _confirmLinking() async {
    setState(() => _isSearching = true);
    try {
      // استدعاء دالة الكوبيت الرسمية والمحكمة لتنفيذ الـ WriteBatch سحابياً
      await context.read<ParentCubit>().linkChild(_codeController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم ربط حساب الابن بنجاح ومزامنة تقاريره حياً! 🎉', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Color(0xFF005F61),
          ),
        );

        setState(() {
          _childFound = false;
          _isSearching = false;
          _codeController.clear();
        });
        
        widget.onTabSwitch(0); // العودة المباشرة للوحة التحكم الرئيسية لولي الأمر
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إتمام عملية الربط: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
        );
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        
        // ==================== 1. الترويسة الاحترافية المتناسقة مع الشاشات السابقة ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 95,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF005F61), Color(0xFF003D3F)], 
                begin: Alignment.topRight, 
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)), // تطابق انحناء الرئيسية لشكل متناسق واحترافي
            ),
          ),
          title: const Text(
            'ربط حساب ابن جديد', 
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        
        // ==================== 2. جسم الشاشة المطور والمنسق بالكامل ====================
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // كارت التعليمات والإرشاد
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(24), 
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF005F61), size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'أدخل "الكود العشوائي" الذي تم توليده داخل ملف الطالب الشخصي لربط حسابه ومتابعة لوحة تقاريره واستيعابه حياً.',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Color(0xFF4B5563), height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'أدخل الكود العشوائي للطالب:', 
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
              ),
              const SizedBox(height: 10),

              // حقل إدخال الكود الفاخر والمنسق بالخط الإنجليزي المخصص للأرقام والأكواد
              TextField(
                controller: _codeController,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), letterSpacing: 1),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [LengthLimitingTextInputFormatter(15)], // حماية وضبط طول الحقل
                decoration: InputDecoration(
                  hintText: 'مثال: FAHEM-XXXX',
                  hintStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFF005F61), size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.5)),
                ),
              ),
              const SizedBox(height: 24),

              // زر البحث الأساسي
              if (!_childFound)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchForChild,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F61), 
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSearching
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('البحث عن الحساب سحابياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

              // ==================== 3. كارت نتيجة البحث المطور والحي الحقيقي ====================
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _childFound
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4), 
                            child: Text('تم العثور على الحساب بنجاح:', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF7F7), 
                              borderRadius: BorderRadius.circular(22), 
                              border: Border.all(color: const Color(0xFF005F61).withAlpha((0.15 * 255).toInt())),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.face_rounded, color: Color(0xFF005F61), size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_foundStudentName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                                      const SizedBox(height: 3),
                                      Text(_foundStudentStage, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // زر تأكيد الربط الفاخر والنهائي لولي الأمر
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isSearching ? null : _confirmLinking,
                              icon: const Icon(Icons.link_rounded, color: Colors.white, size: 20),
                              label: const Text('تأكيد ربط الحساب وتفعيل المتابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE6A100), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}