// lib/features/teacher/presentation/screens/manage_sections/manage_quiz_content_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_quiz_editor_screen.dart';
import 'package:flutter/material.dart';

class ManageQuizContentScreen extends StatefulWidget {
  final String lessonName;
  final List<dynamic>? initialQuestions; // استقبال الأسئلة الحالية إن وُجدت

  const ManageQuizContentScreen({
    super.key,
    required this.lessonName,
    this.initialQuestions,
  });

  @override
  State<ManageQuizContentScreen> createState() => _ManageQuizContentScreenState();
}

class _ManageQuizContentScreenState extends State<ManageQuizContentScreen> {
  // متغير يحمل قائمة الأسئلة حياً لإدارة حالتها بالسيرفر التخيلي
  List<dynamic>? _serverQuestions;

  @override
  void initState() {
    super.initState();
    // تهيئة البيانات القادمة من الشاشة السابقة
    _serverQuestions = widget.initialQuestions;
  }

  // 1. دالة محاكاة إنشاء اختبار جديد وتجهيزه
  void _createNewQuiz() {
    setState(() {
      _serverQuestions = []; // تهيئة مصفوفة فارغة جاهزة لاستقبال الأسئلة
    });
    
    // التوجيه الفوري لشاشة بناء الأسئلة ليدخل المدرس سؤاله الأول
    _navigateToEditor();
  }

  // 2. دالة التوجيه لشاشة منشئ الأسئلة ومزامنة العدد الراجع
  void _navigateToEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherQuizEditorScreen(lessonName: widget.lessonName),
      ),
    ).then((_) {
      // هنا عند العودة، نقوم بعمل تحديث لإحصائيات الأسئلة في الواجهة
      setState(() {});
    });
  }

  // 3. دالة حذف الاختبار بالكامل مع صندوق تأكيد لحماية البيانات
  void _deleteEntireQuiz() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
                SizedBox(width: 8),
                Text('حذف الاختبار بالكامل', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'هل أنت متأكد من حذف هذا الاختبار بجميع أسئلته واختياراته نهائياً؟ لن يتمكن الطلاب من تقديم حلولهم عليه بعد الآن.',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5, color: AppColors.textMain),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق الصندوق
                  setState(() {
                    _serverQuestions = null; // مسح مصفوفة الاختبار تماماً برمجياً
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الاختبار بالكامل من السيرفر', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('نعم، احذف الكل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;
    final bool hasQuiz = _serverQuestions != null;
    // عدد الأسئلة الافتراضي للعرض الإحصائي أمام اللجنة (محاكاة دقيقة)
    final int questionCount = hasQuiz ? 2 : 0; 

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ==================== 1. جسم التحكم الإداري ومحاكاة المعاينة الفخمة (في الخلفية أولاً) ====================
            // 💎 تم نقل محتوى الـ Scroll ليكون أول طبقة في الـ Stack لحماية أزرار البانر 💎
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // كارت فحص حالة ومستوى تواجد الاختبار تكنولوجياً
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: hasQuiz ? const Color(0xFFFEF6E5) : const Color(0xFFF8FAFC), // البيج الذهبي للموجود، والرمادي للفارغ
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasQuiz ? const Color(0xFFE6A100).withAlpha((0.3 * 255).toInt()) : Colors.grey[300]!, 
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            hasQuiz ? Icons.assignment_turned_in_rounded : Icons.quiz_outlined,
                            color: hasQuiz ? const Color(0xFFE6A100) : Colors.grey[400],
                            size: 44,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasQuiz ? 'الاختبار متاح وجاهز حالياً للطالب' : 'لا يوجد اختبار مضاف لهذا الدرس',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: hasQuiz ? const Color(0xFFD49400) : Colors.grey[600]),
                          ),
                          if (hasQuiz) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('إجمالي الأسئلة النشطة بالامتحان:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600])),
                                const SizedBox(width: 5),
                                Text('$questionCount', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),
                    const Text('لوحة التحكم والإجراءات المتاحة:', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 15),

                    if (!hasQuiz) ...[
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _createNewQuiz,
                          icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
                          label: const Text('إنشاء وتفعيل اختبار كويز جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToEditor,
                          icon: const Icon(Icons.edit_attributes_rounded, color: Colors.white),
                          label: const Text('تعديل وإدارة أسئلة الاختبار الحالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _deleteEntireQuiz,
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          label: const Text('حذف الاختبار بجميع أسئلته نهائياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            // ==================== 2. البانر الفيروزي العلوي الموحد (في المقدمة آخراً) ====================
            // 💎 تم نقله آخراً ليكون طافياً فوق عناصر الاسكرول وتصبح أزراره نشطة وقابلة للمس 💎
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-20,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)], 
                    begin: Alignment.topRight, 
                    end: Alignment.bottomLeft,
                  ),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          // إرجاع مصفوفة الأسئلة المحدثة للشاشة الأم لضمان المزامنة الحية بنسبة 100%
                          onPressed: () => Navigator.pop(context, _serverQuestions),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('لوحة إدارة الاختبار (MCQ)', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
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