import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactTeachersScreen extends StatefulWidget {
  const ContactTeachersScreen({super.key});

  @override
  State<ContactTeachersScreen> createState() => _ContactTeachersScreenState();
}

class _ContactTeachersScreenState extends State<ContactTeachersScreen> {

  void _startChatWithTeacher(Map<String, dynamic> teacher, String docId, String studentName) {
    Navigator.pushNamed(
      context, 
      Routes.ChatScreen,
      arguments: {
        'teacherId': docId, 
        'teacherName': teacher['name'] ?? 'معلم',
        'subject': teacher['specialty'] ?? '',
        'studentName': studentName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF005F61), Color(0xFF003D3F)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تواصل مع معلمك',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 4),
              Text(
                'اسأل معلم المادة مباشرة عن النقاط التي تقف أمامك',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        
        body: BlocBuilder<StudentCubit, StudentState>(
          builder: (context, studentState) {
            if (studentState is! StudentLoaded) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
            }

            String currentStudentName = "طالب فاهم";
            try {
              currentStudentName = (studentState as dynamic).studentProfile?['name'] ?? "طالب فاهم";
            } catch (_) {}

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('teachers').snapshots(), 
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final List<Map<String, dynamic>> filteredTeachers = [];
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id; 
                  filteredTeachers.add(data);
                }

                if (filteredTeachers.isEmpty) {
                  return const Center(child: Text('لا يوجد معلمون مسجلون في النظام حالياً', style: TextStyle(fontFamily: 'Cairo')));
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredTeachers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0).copyWith(bottom: 110),
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return _buildTeacherCard(teacher, teacher['id'] ?? '', currentStudentName);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher, String docId, String studentName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEDF7F7),
            child: Icon(Icons.person, color: Color(0xFF005F61), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Text(
                  teacher['name'] ?? 'معلم',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    teacher['specialty'] ?? teacher['subject'] ?? '',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _startChatWithTeacher(teacher, docId, studentName), 
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.white),
            label: const Text('مراسلة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE6A100),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}