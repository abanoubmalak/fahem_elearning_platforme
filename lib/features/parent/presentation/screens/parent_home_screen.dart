// lib/features/parent/presentation/screens/parent_home_screen.dart
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

  void _showDeleteConfirmationDialog(String childId, String childName) {
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
              'هل أنت متأكد من رغبتك في إلغاء ربط حساب ($childName)؟',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold))),
              ElevatedButton(
                onPressed: () {
                  context.read<ParentCubit>().removeChild(childId); // الحذف من الـ Cubit
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إلغاء ربط حساب $childName بنجاح', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
              toolbarHeight: 110,
              automaticallyImplyLeading: false, 
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('لوحة تحكم ولي الأمر', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('مرحباً بحضرتك، تابع التقدم الدراسي لأبنائك وحالة الفواتير أولاً بأول', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white.withAlpha((0.75 * 255).toInt()))),
                    ],
                  ),
                ),
              ),
            ),
            
            body: state.children.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('لا يوجد أبناء مربوطين حالياً.\nانتقل إلى قسم (إضافة طالب) لربط ابنك بالكود.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey, height: 1.5)),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.children.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(bottom: 100),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 52,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.person_pin_rounded, color: Color(0xFF005F61), size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child['name'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(child['stage'], style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22), onPressed: () => _showDeleteConfirmationDialog(child['id'], child['name'])),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: isPaid ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(10)),
                child: Text(isPaid ? 'مدفوع' : 'مطلوب الدفع', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? const Color(0xFF2ECC71) : Colors.redAccent)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFF1F5F9), thickness: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('معدل الاستيعاب والأداء الإجمالي:', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w500)),
              Text('${(performance * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: performance, backgroundColor: const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005F61)), minHeight: 8)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 40,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildReportScreen(
                      childrenData: allChildren,
                      initialChild: child, // تمرير بيانات الطفل الذي تم الضغط عليه
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: const Text('عرض تقرير المواد التفصيلي', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF005F61), side: const BorderSide(color: Color(0xFF005F61), width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }
}