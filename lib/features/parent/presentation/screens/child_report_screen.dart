// lib/features/parent/presentation/screens/child_report_screen.dart
import 'dart:math';
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// نموذج بسيط لتمثيل بيانات الابن الأساسية (الاسم + المرحلة الدراسية)
/// يتم تمريره من الشاشة الأب (مثلاً بعد جلب أبناء ولي الأمر من Firebase)
class ChildProfile {
  final String name;
  final String stage;

  const ChildProfile({required this.name, required this.stage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ChildProfile && other.name == name && other.stage == stage);

  @override
  int get hashCode => name.hashCode ^ stage.hashCode;
}

class ChildReportScreen extends StatefulWidget {
  final List<ChildProfile> children;
  // (اختياري) لتحديد ابن معين عند الدخول للشاشة من بطاقة طالب بعينها
  final ChildProfile? initialChild;

  const ChildReportScreen({
    super.key,
    required this.children,
    this.initialChild,
  });

  @override
  State<ChildReportScreen> createState() => _ChildReportScreenState();
}

class _ChildReportScreenState extends State<ChildReportScreen> {
  late ChildProfile _selectedChild;
  late List<Map<String, dynamic>> _subjectData;

  // قالب المواد الثابت (الاسم، الأيقونة، اللون) — القيم الرقمية تتغير حسب الابن المختار
  static const List<Map<String, dynamic>> _subjectsTemplate = [
    {'subject': 'اللغة العربية', 'icon': Icons.menu_book_rounded, 'color': Color(0xFFEDF7F7)},
    {'subject': 'اللغة الإنجليزية', 'icon': Icons.g_translate_rounded, 'color': Color(0xFFFEF6E5)},
    {'subject': 'الرياضيات', 'icon': Icons.calculate_outlined, 'color': Color(0xFFF1F5F9)},
    {'subject': 'العلوم', 'icon': Icons.biotech_outlined, 'color': Color(0xFFEAFAF1)},
    {'subject': 'الدراسات الاجتماعية', 'icon': Icons.public_rounded, 'color': Color(0xFFFFEAEA)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.initialChild ?? widget.children.first;
    _subjectData = _generateSubjectData(_selectedChild);
  }

  // توليد بيانات أداء ثابتة (Deterministic) لكل ابن بناءً على اسمه، لمحاكاة بيانات حقيقية مختلفة
  // لكل ابن بدون الحاجة لاتصال فعلي بقاعدة البيانات أثناء العرض/المناقشة
  List<Map<String, dynamic>> _generateSubjectData(ChildProfile child) {
    final random = Random(child.name.hashCode);
    return _subjectsTemplate.map((subject) {
      return {
        ...subject,
        'watchProgress': 0.45 + random.nextDouble() * 0.5,
        'quizScore': 0.45 + random.nextDouble() * 0.5,
      };
    }).toList();
  }

  void _onChildChanged(ChildProfile? child) {
    if (child == null || child == _selectedChild) return;
    setState(() {
      _selectedChild = child;
      _subjectData = _generateSubjectData(child);
    });
  }

  double _calculateSubjectScore(double watch, double quiz) {
    return (watch * 0.4) + (quiz * 0.6);
  }

  double _calculateTotalOverallScore() {
    double sum = 0.0;
    for (var data in _subjectData) {
      sum += _calculateSubjectScore(data['watchProgress'], data['quizScore']);
    }
    return sum / _subjectData.length;
  }

  @override
  Widget build(BuildContext context) {
    final double overallScore = _calculateTotalOverallScore();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Column(
          children: [
            _buildHeader(overallScore),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                itemCount: _subjectData.length,
                itemBuilder: (context, index) {
                  final data = _subjectData[index];
                  final double finalSubjectScore = _calculateSubjectScore(data['watchProgress'], data['quizScore']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: data['color'], borderRadius: BorderRadius.circular(12)),
                              child: Icon(data['icon'], color: const Color(0xFF005F61), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                data['subject'],
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(finalSubjectScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005F61)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: finalSubjectScore,
                            backgroundColor: const Color(0xFFF1F5F9),
                            color: const Color(0xFF005F61),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReportSubTile(
                                label: 'مشاهدة (40%)',
                                value: (data['watchProgress'] * 100).toStringAsFixed(0),
                                icon: Icons.play_circle_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildReportSubTile(
                                label: 'اختبار (60%)',
                                value: (data['quizScore'] * 100).toStringAsFixed(0),
                                icon: Icons.assignment_outlined,
                                color: const Color(0xFFE6A100),
                              ),
                            ),
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

  // ==================== الترويسة العلوية المتدرجة + محدد الابن ====================
  Widget _buildHeader(double overallScore) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF005F61), Color(0xFF003D3F)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25.0, top: 10.0),
          child: Column(
            children: [
              // سطر التحكم العلوي وزر الرجوع
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'تقرير الأداء',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // محدد الابن — يظهر فقط لو في أكتر من ابن مرتبط بالحساب
              widget.children.length > 1
                  ? _buildChildSelector()
                  : Text(
                      _selectedChild.name,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),

              const SizedBox(height: 18),

              // العداد الدائري المركزي الكبير للنسبة الإجمالية
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: overallScore,
                      strokeWidth: 10,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFFE6A100),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(overallScore * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                _selectedChild.stage,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white.withAlpha((0.8 * 255).toInt())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // قائمة منسدلة بتصميم "زجاجي" شفاف يتماشى مع خلفية الهيدر الغامقة
  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChildProfile>(
          value: _selectedChild,
          isDense: true,
          dropdownColor: const Color(0xFF005F61),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          onChanged: _onChildChanged,
          // النص المعروض داخل الـ Dropdown نفسه (لما يكون مقفول)
          selectedItemBuilder: (context) {
            return widget.children.map((child) {
              return Center(
                child: Text(
                  child.name,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
              );
            }).toList();
          },
          // عناصر القائمة المنسدلة نفسها
          items: widget.children.map((child) {
            return DropdownMenuItem(
              value: child,
              child: Text(
                child.name,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
              ),
            );
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
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '%$value',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.grey[700]),
        ),
      ],
    );
  }
}