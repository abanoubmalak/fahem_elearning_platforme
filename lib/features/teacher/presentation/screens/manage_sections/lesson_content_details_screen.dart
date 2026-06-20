// // lib/features/teacher/presentation/screens/manage_sections/lesson_content_details_screen.dart
// import 'package:fahem/core/constants/colors.dart';
// import 'package:flutter/material.dart';

// class LessonContentDetailsScreen extends StatefulWidget {
//   final String lessonName;
//   const LessonContentDetailsScreen({super.key, required this.lessonName});

//   @override
//   State<LessonContentDetailsScreen> createState() => _LessonContentDetailsScreenState();
// }

// class _LessonContentDetailsScreenState extends State<LessonContentDetailsScreen> {
//   // متغير لتخزين نص ملخص الدرس حياً ومزامنته برمجياً
//   String _lessonSummaryText = 'في هذا الدرس، نتعلم التعبير الرمزي عن الدالة وكيفية تحديد المجال والمجال المقابل، بالإضافة إلى التعرف على صور عناصر مجال الدالة بواسطة قاعدة الدالة الرياضية الحيوية.';

//   // دالة فتح صندوق تحرير الملخص النصي (Text Editor BottomSheet) لحماية وتسهيل تجربة المدرس
//   void _openEditSummaryBottomSheet() {
//     final TextEditingController summaryController = TextEditingController(text: _lessonSummaryText);

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
//       ),
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(context).viewInsets.bottom + 30),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'تحرير الملخص النصي للدرس',
//                 style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
//               ),
//               const SizedBox(height: 4),
//               const Text('اكتب أو الصق نص الشرح المباشر الذي سيظهر في شاشة الطالب كتلقين معرفي منسق.', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
//               const SizedBox(height: 20),

//               // حقل إدخال نصي متعدد الأسطر مرن ومحمي من الـ Overflow
//               TextField(
//                 controller: summaryController,
//                 maxLines: 6, // مساحة مريحة للكتابة
//                 keyboardType: TextInputType.multiline,
//                 style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, height: 1.5, color: AppColors.textMain),
//                 decoration: InputDecoration(
//                   hintText: 'اكتب خلاصة الشرح هنا...',
//                   hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
//                   filled: true,
//                   fillColor: const Color(0xFFF8FAFC),
//                   enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
//                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.2)),
//                 ),
//               ),
//               const SizedBox(height: 25),

//               // زر حفظ وتحديث الحالة في الـ State
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (summaryController.text.trim().isNotEmpty) {
//                       setState(() {
//                         _lessonSummaryText = summaryController.text.trim(); // تحديث النص حياً
//                       });
//                     }
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('تم تحديث وحفظ نص الملخص بنجاح وبثه للطلاب', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.primary),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF005F61), 
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), 
//                     elevation: 0,
//                   ),
//                   child: const Text('حفظ التعديلات النصية', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double headerHeight = MediaQuery.of(context).size.height * 0.20;

//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Stack(
//           children: [
//             // ==================== البانر العلوي الموحد ====================
//             Positioned(
//               top: 0, left: 0, right: 0, height: headerHeight,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF005F61), Color(0xFF003D3F)], 
//                     begin: Alignment.topRight, 
//                     end: Alignment.bottomLeft,
//                   ),
//                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
//                 ),
//                 child: SafeArea(
//                   bottom: false,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
//                               const Text('إدارة ورفع العناصر الأساسية الثلاثة للدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // ==================== تقسيم المحتويات الثلاثة المحددة بدقة ====================
//             Positioned.fill(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('العناصر النشطة في هذا الدرس:', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
//                     const SizedBox(height: 12),

//                     // 1️⃣ كارت فيديو الشرح
//                     _buildContentComponentCard(
//                       title: 'فيديو الشرح الأساسي',
//                       subtitle: 'رابط فيديو الدرس المرفوع على سيرفر يوتيوب',
//                       status: 'مرفوع حالياً وعامل نشط',
//                       icon: Icons.play_circle_fill_rounded,
//                       color: const Color(0xFFEDF7F7),
//                       onActionPressed: () {},
//                     ),

//                     // 2️⃣ 💎 كارت الملخص النصي المطور والمحدث تكنولوجياً 💎
//                     _buildContentComponentCard(
//                       title: 'الملخص النصي المكتوب',
//                       subtitle: _lessonSummaryText, // عرض نص الملخص الحقيقي مباشرة كـ Preview مصغر
//                       status: 'مكتوب ونشط على شاشات الطلاب',
//                       icon: Icons.article_rounded, // أيقونة مستند نصي واضحة بدلاً من الـ PDF
//                       color: const Color(0xFFE8F8F5),
//                       actionLabel: 'تعديل النص',
//                       onActionPressed: _openEditSummaryBottomSheet, // فتح محرر النصوص المطور عند النقر
//                     ),

//                     // 3️⃣ كارت امتحان الاختيارات (MCQ)
//                     _buildContentComponentCard(
//                       title: 'امتحان الاختيارات المتعددة (MCQ)',
//                       subtitle: 'كويز لقياس مدى فهم واستيعاب الطالب للدرس',
//                       status: 'يحتوي على (10) أسئلة اختبارية نشطة',
//                       icon: Icons.assignment_turned_in_rounded,
//                       color: const Color(0xFFFEF6E5),
//                       accentColor: const Color(0xFFE6A100),
//                       actionLabel: 'تعديل الأسئلة',
//                       onActionPressed: () {},
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // باني كروت العناصر الآمن تماماً والمحمي هندسياً من الـ Overflow
//   Widget _buildContentComponentCard({
//     required String title,
//     required String subtitle,
//     required String status,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onActionPressed,
//     Color accentColor = const Color(0xFF005F61),
//     String actionLabel = 'تحديث المحتوى',
//     bool isAlert = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 46, height: 46,
//                 decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
//                 child: Icon(icon, color: isAlert ? Colors.redAccent : accentColor, size: 24),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
//                     const SizedBox(height: 2),
//                     Text(subtitle, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider(color: Color(0xFFF1F5F9))),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   status, 
//                   style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: isAlert ? Colors.redAccent : Colors.grey[600]),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               TextButton(
//                 onPressed: onActionPressed,
//                 style: TextButton.styleFrom(
//                   foregroundColor: accentColor,
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(actionLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
//                     const SizedBox(width: 2),
//                     const Icon(Icons.arrow_forward_rounded, size: 14),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }