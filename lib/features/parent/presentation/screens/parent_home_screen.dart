// lib/features/parent/presentation/screens/parent_home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'child_report_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  String _parentName = 'ولي الأمر';

  @override
  void initState() {
    super.initState();
    _fetchParentName(); 
  }

  void _fetchParentName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot parentDoc = await FirebaseFirestore.instance
            .collection('parents')
            .doc(user.uid)
            .get();
        if (parentDoc.exists && parentDoc.data() != null && mounted) {
          setState(() {
            _parentName = parentDoc['name'] ?? 'ولي الأمر';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب اسم ولي الأمر: $e');
    }
  }

  // 💎 دالة إظهار نافذة الحذف مأمنة تماماً ضد أخطاء الـ Provider 💎
  void _showDeleteConfirmationDialog(String childId, String childName) {
    // 👈 الحل السحري: كبسلة وامساك الـ Cubit من الـ context الخارجي للشاشة قبل بناء الـ Route الجديد
    final parentCubit = context.read<ParentCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // 👈 تغيير الاسم إلى dialogContext لمنع التداخل
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
                SizedBox(width: 10),
                Text('إلغاء ربط الابن', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'هل أنت متأكد من رغبتك في إلغاء ربط حساب ($childName)؟ ستفقد القدرة على متابعة تقاريره الحية.',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), 
                child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold))
              ),
              ElevatedButton(
                onPressed: () {
                  parentCubit.removeChild(childId); // 👈 استخدام نسخة الـ Cubit المأمنة سحابياً بنجاح
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم إلغاء ربط حساب $childName بنجاح', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent)
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentCubit, ParentState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 125,
              automaticallyImplyLeading: false, 
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)], 
                    begin: Alignment.topRight, 
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'أهلاً بك، أ/ $_parentName 👋', 
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'تابع التقدم الدراسي لأبنائك وحالة الفواتير أولاً بأول', 
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: Colors.white.withAlpha((0.75 * 255).toInt())),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(25), shape: BoxShape.circle),
                        child: const Icon(Icons.supervisor_account_rounded, color: Color(0xFFE6A100), size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            body: state.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF005F61), strokeWidth: 4))
                : state.children.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(color: Color(0xFFEDF7F7), shape: BoxShape.circle),
                                child: const Icon(Icons.person_add_disabled_rounded, size: 55, color: Color(0xFF005F61)),
                              ),
                              const SizedBox(height: 20),
                              const Text('لا يوجد أبناء مربوطين حالياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                              const SizedBox(height: 6),
                              const Text('انتقل إلى قسم (إضافة طالب) بالأسفل وقم بإدخال الكود العشوائي لربط حساب ابنك حياً.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.grey, height: 1.5)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.children.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22).copyWith(bottom: 110),
                        itemBuilder: (context, index) {
                          return _buildChildCard(state.children[index], state.children);
                        },
                      ),
          ),
        );
      },
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child, List<Map<String, dynamic>> allChildren) {
    final bool isPaid = child['isPaid'];
    final double performance = child['overallPerformance'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 54,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.person_pin_rounded, color: Color(0xFF005F61), size: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child['name'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(child['stage'], style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22), 
                onPressed: () => _showDeleteConfirmationDialog(child['id'], child['name']),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: isPaid ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(12)),
                child: Text(isPaid ? 'مدفوع' : 'مطلوب الدفع', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? const Color(0xFF2ECC71) : Colors.redAccent)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFF1F5F9), thickness: 1.2)),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded( 
                child: Text(
                  'معدل الاستيعاب والأداء الإجمالي للابن:', 
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, 
                ),
              ),
              const SizedBox(width: 10), 
              Text('${(performance * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
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
          SizedBox(
            width: double.infinity, height: 42,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildReportScreen(
                      childrenData: allChildren,
                      initialChild: child, 
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_outlined, size: 17),
              label: const Text('عرض تقرير المواد التفصيلي', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF005F61), 
                side: const BorderSide(color: Color(0xFF005F61), width: 1.3), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}