import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/helpers/ui_helpers.dart'; 
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart'; 
import 'package:fahem/features/lessons/presentation/screens/subject_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../widgets/course_list_item.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<Courses> {
  final int _currentIndex = 2; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentCubit>().loadStudentDashboard();
      }
    });
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
          toolbarHeight: 90, 
          automaticallyImplyLeading: false, 
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF005F61), 
                  Color(0xFF003D3F), 
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'دوراتي الدراسيّة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'تابع تقدمك في المواد والمناهج العلمية أولاً بأول',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        body: BlocBuilder<StudentCubit, StudentState>(
          builder: (context, state) {
            if (state is StudentLoading || state is StudentInitial) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF005F61),
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل مناهجك الدراسية...',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F61),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is StudentError) {
              return Center(
                child: Text(
                  state.message, 
                  style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF005F61), fontWeight: FontWeight.bold)
                )
              );
            }

            if (state is StudentLoaded) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(), 
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.subjects.length, 
                      itemBuilder: (context, index) {
                        final subject = state.subjects[index];
                        
                        return GestureDetector(
                          onTap: () {
                            if (subject.isUnlocked) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubjectDetailsScreen(
                                    subjectId: subject.id, 
                                    subjectTitle: subject.title,
                                    studentTerm: state.term, 
                                  ),
                                ),
                              );
                            } else {
                              UiHelpers.showSubscriptionPaywall(context);
                            }
                          },
                          child: CourseListItem(
                            title: subject.title,
                            progress: subject.progress,
                            icon: subject.icon,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}