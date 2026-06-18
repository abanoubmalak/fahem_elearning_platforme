// lib/features/lessons/presentation/screens/lessom_summery_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class LessonSummaryScreen extends StatelessWidget {
  final String lessonTitle;
  final List<dynamic> summaries; // 👈 1. استقبال مصفوفة الملخصات

  const LessonSummaryScreen({
    super.key,
    required this.lessonTitle,
    required this.summaries,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF004D4F),
        body: Column(
          children: [
            // ── البانر العلوي ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF004D4F), Color(0xFF007A7C)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const CircleAvatar(radius: 32, backgroundColor: Colors.white24, child: Icon(Icons.description_rounded, color: Colors.white, size: 34)),
                    const SizedBox(height: 12),
                    const Text('الملخص التنفيذي والسريع', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ── كارت عرض الملخصات الديناميكي ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lessonTitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                        const SizedBox(height: 20),

                        // 👈 2. رسم الملخصات حياً من مصفوفة البيانات
                        summaries.isEmpty 
                        ? const Center(child: Text('لا توجد ملخصات لهذا الدرس حالياً.', style: TextStyle(fontFamily: 'Cairo')))
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: summaries.length,
                          itemBuilder: (context, index) {
                            final summary = summaries[index];
                            return _buildSummaryStructureCard(
                              originalText: summary['originalText'] ?? '',
                              summaryText: summary['summaryText'] ?? '',
                            );
                          },
                        ),
                        const SizedBox(height: 60),
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

  // ويدجت الكروت الهيكلية
  Widget _buildSummaryStructureCard({required String originalText, required String summaryText}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(originalText, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF005F61), height: 1.4)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFEDF2F7), thickness: 1.2)),
          Text(summaryText, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, color: AppColors.textMain, height: 1.6)),
        ],
      ),
    );
  }
}