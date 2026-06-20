// lib/features/parent/presentation/screens/child_report_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 استيراد الفايرستور حياً
import 'package:flutter/material.dart';

class ChildReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> childrenData;
  final Map<String, dynamic>? initialChild;

  const ChildReportScreen({
    super.key,
    required this.childrenData,
    this.initialChild,
  });

  @override
  State<ChildReportScreen> createState() => _ChildReportScreenState();
}

class _ChildReportScreenState extends State<ChildReportScreen> {
  Map<String, dynamic>? _selectedChild;
  late List<Map<String, dynamic>> _subjectData;
  bool _isLoading = true; // 👈 حارس حالة التحميل السحابي

  // 💎 ربط قائمة المواد بالـ IDs الرسمية المعتمدة بقاعدة بيانات فاهم
  static const List<Map<String, dynamic>> _subjectsTemplate = [
    {'id': 'ara', 'subject': 'اللغة العربية', 'icon': Icons.menu_book_rounded, 'color': Color(0xFFEDF7F7)},
    {'id': 'eng', 'subject': 'اللغة الإنجليزية', 'icon': Icons.g_translate_rounded, 'color': Color(0xFFFEF6E5)},
    {'id': 'math', 'subject': 'الرياضيات', 'icon': Icons.calculate_outlined, 'color': Color(0xFFF1F5F9)},
    {'id': 'sci', 'subject': 'العلوم', 'icon': Icons.biotech_outlined, 'color': Color(0xFFEAFAF1)}, // sci متوافق مع السيرفر
    {'id': 'soc', 'subject': 'الدراسات الاجتماعية', 'icon': Icons.public_rounded, 'color': Color(0xFFFFEAEA)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.childrenData.isNotEmpty) {
      _selectedChild = widget.initialChild ?? widget.childrenData.first;
      // تهيئة مبدئية مأمنة بنسبة صفر لمكافحة الأخطاء البصرية أثناء التحميل
      _subjectData = _subjectsTemplate.map((s) => {...s, 'watchProgress': 0.0, 'quizScore': 0.0}).toList();
      _loadLiveChildReport(_selectedChild!);
    } else {
      _isLoading = false;
    }
  }

  // 💎 دالة جلب تقارير أداء المواد التفصيلي الحقيقي للابن من الفايرستور
  Future<void> _loadLiveChildReport(Map<String, dynamic> child) async {
    setState(() => _isLoading = true);
    try {
      // جلب سجلات تقدم الطالب بالكامل المربوطة بمعرفه الفرعي
      final QuerySnapshot progressSnap = await FirebaseFirestore.instance
          .collection('student_progress')
          .where('studentId', isEqualTo: child['id'])
          .get();

      // فلترة واحتساب النسب الحركية لكل مادة بشكل مستقل
      final List<Map<String, dynamic>> updatedData = _subjectsTemplate.map((subject) {
        final subjectDocs = progressSnap.docs.where((doc) {
          final pData = doc.data() as Map<String, dynamic>;
          return pData['subjectId'] == subject['id'];
        }).toList();

        // إذا لم يبدأ الطالب المادة بعد، تظهر بنسبة 0%
        if (subjectDocs.isEmpty) {
          return {
            ...subject,
            'watchProgress': 0.0,
            'quizScore': 0.0,
          };
        }

        int watchCount = 0;
        double quizSum = 0.0;

        for (var doc in subjectDocs) {
          final pData = doc.data() as Map<String, dynamic>;
          if (pData['isVideoWatched'] == true) {
            watchCount++;
          }
          quizSum += ((pData['quizScore'] ?? 0) as num).toDouble();
        }

        return {
          ...subject,
          'watchProgress': watchCount / subjectDocs.length,
          'quizScore': (quizSum / subjectDocs.length) / 10.0, // القسمة على 10 لتصبح نسبة بين 0.0 و 1.0 للـ Progress Bar
        };
      }).toList();

      if (mounted) {
        setState(() {
          _subjectData = updatedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب تقرير أداء الابن: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onChildChanged(Map<String, dynamic>? child) {
    if (child == null || child['id'] == _selectedChild?['id']) return;
    setState(() {
      _selectedChild = child;
    });
    _loadLiveChildReport(child); // إعادة جلب التقارير حياً فور تبديل الابن
  }

  double _calculateSubjectScore(double watch, double quiz) => (watch * 0.4) + (quiz * 0.6);

  double _calculateTotalOverallScore() {
    if (_subjectData.isEmpty) return 0.0;
    double sum = 0.0;
    for (var data in _subjectData) sum += _calculateSubjectScore(data['watchProgress'], data['quizScore']);
    return sum / _subjectData.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.childrenData.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(backgroundColor: const Color(0xFF005F61), title: const Text('تقرير الأداء', style: TextStyle(fontFamily: 'Cairo'))),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('لا يوجد أبناء مربوطين بحسابك', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('يرجى ربط حساب ابنك أولاً عبر كود الربط لمشاهدة تقارير الأداء.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final double overallScore = _calculateTotalOverallScore();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(overallScore),
            Expanded(
              // 💎 دمج مؤشر التحميل بسلاسة لضمان جودة الأداء البصري وثبات التصميم 💎
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF005F61), strokeWidth: 4))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      itemCount: _subjectData.length,
                      itemBuilder: (context, index) {
                        final data = _subjectData[index];
                        final double finalSubjectScore = _calculateSubjectScore(data['watchProgress'], data['quizScore']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: data['color'], borderRadius: BorderRadius.circular(12)), child: Icon(data['icon'], color: const Color(0xFF005F61), size: 22)),
                                  const SizedBox(width: 14),
                                  Expanded(child: Text(data['subject'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  Text('${(finalSubjectScore * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005F61))),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: finalSubjectScore, backgroundColor: const Color(0xFFF1F5F9), color: const Color(0xFF005F61), minHeight: 6)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildReportSubTile(label: 'مشاهدة (40%)', value: (data['watchProgress'] * 100).toStringAsFixed(0), icon: Icons.play_circle_outline_rounded)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildReportSubTile(label: 'اختبار (60%)', value: (data['quizScore'] * 100).toStringAsFixed(0), icon: Icons.assignment_outlined, color: const Color(0xFFE6A100))),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double overallScore) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF005F61), Color(0xFF003D3F)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25.0, top: 10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 4),
                    const Expanded(child: Text('تقرير الأداء', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              widget.childrenData.length > 1
                  ? _buildChildSelector()
                  : Text(_selectedChild!['name'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 18),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 110, height: 110, child: CircularProgressIndicator(value: overallScore, strokeWidth: 10, backgroundColor: Colors.white12, color: const Color(0xFFE6A100), strokeCap: StrokeCap.round)),
                  Text('${(overallScore * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 15),
              Text(_selectedChild!['stage'], style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white.withAlpha((0.8 * 255).toInt()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(color: Colors.white.withAlpha(28), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withAlpha(60))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedChild,
          isDense: true,
          dropdownColor: const Color(0xFF005F61),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          onChanged: _onChildChanged,
          selectedItemBuilder: (context) {
            return widget.childrenData.map((child) => Center(child: Text(child['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))).toList();
          },
          items: widget.childrenData.map((child) {
            return DropdownMenuItem(value: child, child: Text(child['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportSubTile({required String label, required String value, required IconData icon, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(child: Text('$label:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text('%$value', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.grey[700])),
      ],
    );
  }
}