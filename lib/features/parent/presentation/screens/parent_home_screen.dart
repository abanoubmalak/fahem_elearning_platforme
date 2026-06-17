// lib/features/parent/presentation/screens/parent_home_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'child_report_screen.dart';
import 'payment_checkout_screen.dart';
import 'parent_profile_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {

  
  // قائمة الأبناء المربوطة ديناميكياً
  final List<Map<String, dynamic>> _children = [
    {
      'name': 'أحمد أبانوب',
      'stage': 'الصف الأول الإعدادي',
      'overallPerformance': 0.82, 
      'isPaid': true, 
    },
    {
      'name': 'مريم أبانوب',
      'stage': 'الصف الرابع الابتدائي',
      'overallPerformance': 0.54,
      'isPaid': false, 
    },
  ];

  // دالة إظهار صندوق تأكيد الحذف
  void _showDeleteConfirmationDialog(int index, String childName) {
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
                SizedBox(width: 10),
                Text('إلغاء ربط الابن', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'هل أنت متأكد من رغبتك في إلغاء ربط حساب ($childName)؟ لن تتمكن من متابعة تقاريره أو دفع فواتيره إلا بإعادة إدخال كود الربط مجدداً.',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5, color: AppColors.textMain),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _children.removeAt(index); // الحذف الفعلي برمجياً من الـ List وتحديث الواجهة
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إلغاء ربط حساب $childName بنجاح', style: const TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة إضافة/ربط ابن جديد عبر الكود الثابت
  void _openLinkChildBottomSheet() {
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
                'ربط حساب ابن جديد',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 6),
              Text(
                'أدخل كود الربط الثابت الموجود في صفحة حساب ابنك الشخصية (Profile)',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'مثال: FAHEM-XXXX-XX',
                  hintStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFF005F61)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.2)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم ربط حساب الابن بنجاح ومزامنة تقاريره الدراسية', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF005F61)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F61),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('تأكيد ربط الحساب الموحد', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        // ==================== 1. الترويسة العلوية باستخدام AppBar مستقر ====================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 110, // مساحة مريحة لاستيعاب العنوان والترحيب والزر الجانبي
          automaticallyImplyLeading: false, 
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)],
              ),
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(30),
              //   bottomRight: Radius.circular(30),
              // ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'لوحة تحكم ولي الأمر',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const ParentProfileScreen()),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'مرحباً بحضرتك، تابع التقدم الدراسي لأبنائك وحالة الفواتير أولاً بأول',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white.withAlpha((0.75 * 255).toInt())),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // ==================== 2. قائمة كروت الأبناء التفاعلية المحدثة ====================
        body: _children.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'لا يوجد أبناء مربوطين حالياً.\nاضغط على زر (+) بالأسفل لإضافة ابن.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey, height: 1.5),
                  ),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _children.length,
                // بادينج داخلي مريح لحماية الكروت من الحجب خلف البار السفلي أو زر الإضافة العائم
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(bottom: 100),
                itemBuilder: (context, index) {
                  final child = _children[index];
                  return _buildChildCard(child, index);
                },
              ),

        // ==================== 3. زر الإضافة العائم المحسن ====================
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _openLinkChildBottomSheet,
        //   backgroundColor: const Color(0xFFE6A100), // اللون الذهبي
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //   child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        // ),
      ),
    );
  }

  // ويدجت بناء كارت الابن المتكامل
  Widget _buildChildCard(Map<String, dynamic> child, int index) {
    final bool isPaid = child['isPaid'];
    final double performance = child['overallPerformance'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // السطر الأول: الأفاتار، بيانات الابن، زر الحذف، وبادج الدفع
          Row(
            children: [
              Container(
                width: 50,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_pin_rounded, color: Color(0xFF005F61), size: 32),
              ),
              const SizedBox(width: 12),
              
              // بيانات الابن الدراسية محمية بالكامل بـ Expanded لمنع الـ Overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['name'],
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child['stage'],
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // زر إلغاء الربط
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                tooltip: 'إلغاء ربط الابن',
                onPressed: () => _showDeleteConfirmationDialog(index, child['name']),
              ),
              
              const SizedBox(width: 4),

              // بادج حالة دفع الاشتراك
              GestureDetector(
                onTap: () async {
                  if (!isPaid) {
                    final bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentCheckoutScreen(packageAmount: 100,children: ["Abanoub","Mian"]),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        child['isPaid'] = true;
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA), 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPaid ? 'مدفوع' : 'مطلوب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? const Color(0xFF2ECC71) : Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),

          // السطر الثاني: مؤشر الأداء العام
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'معدل الاستيعاب والأداء الإجمالي:',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.w500),
              ),
              Text(
                '${(performance * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF005F61)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: performance,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005F61)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // زر الدخول السريع للتقارير التفصيلية
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildReportScreen(children: [
                      ChildProfile(name: 'أحمد', stage: 'الصف الرابع'),
                      ChildProfile(name: 'مريم', stage: 'الصف الثاني'),
  ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: const Text(
                'عرض تقرير المواد التفصيلي',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF005F61),
                side: const BorderSide(color: Color(0xFF005F61), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}