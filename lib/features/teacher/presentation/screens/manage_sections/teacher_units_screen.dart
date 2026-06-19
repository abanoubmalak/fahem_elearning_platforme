// lib/features/teacher/presentation/screens/manage_sections/teacher_units_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/features/teacher/presentation/cubit/teacher_academic_cubit.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_lessons_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherUnitsScreen extends StatefulWidget {
  final String stageName;
  final String subjectId; 
  final String term;      

  const TeacherUnitsScreen({
    super.key,
    required this.stageName,
    this.subjectId = 'sci', 
    this.term = 'الترم الثاني',
  });

  @override
  State<TeacherUnitsScreen> createState() => _TeacherUnitsScreenState();
}

class _TeacherUnitsScreenState extends State<TeacherUnitsScreen> {
  
  void _openAddUnitBottomSheet(List<dynamic> currentUnits) {
    final TextEditingController unitController = TextEditingController();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة وحدة دراسية جديدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 18),
              TextField(
                controller: unitController,
                decoration: InputDecoration(hintText: 'مثال: الوحدة الأولى: العلاقات والدوال', hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12), filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (unitController.text.trim().isNotEmpty) {
                      BlocProvider.of<TeacherAcademicCubit>(context).addUnit(
                        subjectId: widget.subjectId, 
                        term: widget.term, 
                        unitName: unitController.text.trim(), 
                        currentUnits: currentUnits
                      );
                      Navigator.pop(sheetContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('إضافة وتأكيد وعرض', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
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

    return BlocProvider(
      create: (context) => TeacherAcademicCubit()..listenToSyllabus(subjectId: widget.subjectId, term: widget.term),
      child: BlocBuilder<TeacherAcademicCubit, TeacherAcademicState>(
        builder: (context, state) {
          List<dynamic> units = [];
          if (state is AcademicLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF005F61))));
          }
          if (state is AcademicLoaded) {
            units = state.units;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openAddUnitBottomSheet(units),
              backgroundColor: const Color(0xFFE6A100),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('إضافة وحدة جديدة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: units.isEmpty
                        ? const Center(child: Text('المنهج فارغ، اضغط على زر الإضافة لتأسيس الوحدات.', style: TextStyle(fontFamily: 'Cairo')))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                            itemCount: units.length,
                            itemBuilder: (context, index) {
                              final unit = units[index];
                              final List<dynamic> lessons = unit['lessons'] ?? [];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))]),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: CircleAvatar(backgroundColor: const Color(0xFFEDF7F7), child: Text('${index + 1}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF005F61)))),
                                  title: Text(unit['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                                  subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('يحتوي على ${lessons.length} دروس مقررة حياً', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey))),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: BlocProvider.of<TeacherAcademicCubit>(context),
                                          child: TeacherLessonsScreen(
                                            unitName: unit['title'] ?? '',
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
                                // 👈 تم تعديل المعامل إلى icon لتصفير الخطأ نهائياً
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18), 
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.stageName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), const Text('لوحة التحكم وإدارة الوحدات السحابية مقرر', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70))])),
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
      ),
    );
  }
}