import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_academic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lesson_content_hub_screen.dart'; 

class TeacherLessonsScreen extends StatefulWidget {
  final String unitName;
  final String stageName;
  final String subjectId; 
  final String term;      

  const TeacherLessonsScreen({
    super.key, 
    required this.unitName, 
    required this.stageName,
    required this.subjectId,
    required this.term,
  });

  @override
  State<TeacherLessonsScreen> createState() => _TeacherLessonsScreenState();
}

class _TeacherLessonsScreenState extends State<TeacherLessonsScreen> {

void _openAddLessonBottomSheet() { 
  final TextEditingController lessonController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('إضافة درس جديد للوحدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            TextField(
              controller: lessonController,
              decoration: InputDecoration(hintText: 'مثال: الدرس الأول...', filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (lessonController.text.trim().isNotEmpty) {
                    BlocProvider.of<TeacherAcademicCubit>(context).addLesson(
                      subjectId: widget.subjectId,
                      term: widget.term,
                      unitTitle: widget.unitName,
                      lessonName: lessonController.text.trim(),
                    );
                    Navigator.pop(sheetContext);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('إضافة الدرس', style: TextStyle(color: Colors.white)),
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
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    return BlocBuilder<TeacherAcademicCubit, TeacherAcademicState>(
      builder: (context, state) {
        List<dynamic> currentUnits = [];
        List<dynamic> lessons = [];

        if (state is AcademicLoaded) {
          currentUnits = state.units;
          final currentUnit = currentUnits.firstWhere((u) => u['title'] == widget.unitName, orElse: () => {});
          lessons = currentUnit['lessons'] ?? [];
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _openAddLessonBottomSheet(), 
  backgroundColor: const Color(0xFFE6A100),
  icon: const Icon(Icons.add_rounded, color: Colors.white),
  label: const Text('إضافة درس جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                Positioned.fill(
                  child: lessons.isEmpty
                      ? const Center(child: Text('لا توجد دروس مضافة في هذه الوحدة حالياً.', style: TextStyle(fontFamily: 'Cairo')))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = lessons[index];
                            final String lessonTitle = lesson['title'] ?? '';
                            final bool hasVideo = (lesson['videoUrl'] ?? '').toString().isNotEmpty;
                            final bool hasQuiz = (lesson['questions'] ?? []).isNotEmpty;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: const CircleAvatar(backgroundColor: Color(0xFFEDF7F7), child: Icon(Icons.menu_book_rounded, color: Color(0xFF005F61), size: 20)),
                                title: Text(lessonTitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      _buildContentIndicator(Icons.play_circle_outline, 'فيديو', hasVideo),
                                      const SizedBox(width: 12),
                                      _buildContentIndicator(Icons.assignment_outlined, 'اختبار', hasQuiz),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.settings_suggest_rounded, size: 18, color: Color(0xFF005F61)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: BlocProvider.of<TeacherAcademicCubit>(context),
                                        child: LessonContentHubScreen(
                                          lessonName: lessonTitle,
                                          unitName: widget.unitName,
                                          stageName: widget.stageName,
                                          subjectId: widget.subjectId,
                                          term: widget.term,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0, height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18), 
                              onPressed: () => Navigator.pop(context), 
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(widget.unitName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(widget.stageName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70)),
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
      },
    );
  }

  Widget _buildContentIndicator(IconData icon, String label, bool isAvailable) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isAvailable ? const Color(0xFF27AE60) : Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: isAvailable ? const Color(0xFF27AE60) : Colors.grey, fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}