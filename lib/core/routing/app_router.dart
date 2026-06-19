// lib/core/routing/app_router.dart
import 'package:fahem/features/admin/presentation/screens/add_teacher_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_financials_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_main_wrapper.dart';
import 'package:fahem/features/admin/presentation/screens/admin_parents_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_students_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_teachers_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/edit_parent_screen.dart';
import 'package:fahem/features/admin/presentation/screens/edit_student_screen.dart';
import 'package:fahem/features/admin/presentation/screens/edit_teacher_screen.dart';
import 'package:fahem/features/admin/presentation/screens/parent_details_screen.dart';
import 'package:fahem/features/admin/presentation/screens/student_details_screen.dart';
import 'package:fahem/features/admin/presentation/screens/teacher_details_screen.dart';


import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart'; 
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fahem/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:fahem/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:fahem/features/courses/presentation/screens/courses.dart';
import 'package:fahem/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import 'package:fahem/features/forgot_password/presentation/screens/reset_password_screen.dart';
import 'package:fahem/features/forgot_password/presentation/screens/verification_screen.dart';
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart';
import 'package:fahem/features/home/presentation/screens/home.dart';
import 'package:fahem/features/home/presentation/screens/main_wrapper.dart';
import 'package:fahem/features/lessons/presentation/screens/lessom_summery_screen.dart';
import 'package:fahem/features/lessons/presentation/screens/quiz_screen.dart';
import 'package:fahem/features/lessons/presentation/screens/subject_details_screen.dart';
import 'package:fahem/features/lessons/presentation/widgets/video_player_screen.dart';
import 'package:fahem/features/auth/presentation/screens/login.dart';
import 'package:fahem/features/parent/presentation/screens/child_report_screen.dart';
import 'package:fahem/features/parent/presentation/screens/link_child_screen.dart';
import 'package:fahem/features/parent/presentation/screens/parent_home_screen.dart';
import 'package:fahem/features/parent/presentation/screens/parent_profile_screen.dart';
import 'package:fahem/features/parent/presentation/screens/parent_wrapper.dart';
import 'package:fahem/features/parent/presentation/screens/payment_checkout_screen.dart';
import 'package:fahem/features/performance/presentation/screens/performance_screen.dart';
import 'package:fahem/features/profile/presentation/screens/profile_screen.dart';
import 'package:fahem/features/auth/presentation/screens/sign_up.dart';
import 'package:fahem/features/splash/presentation/screens/splash_screen.dart'; 
import 'package:fahem/features/teacher/presentation/screens/manage_sections/add_lesson_content_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/lesson_content_hub_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/manage_media_content_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/manage_quiz_content_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/manage_text_summary_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_lessons_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_quiz_editor_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/manage_sections/teacher_units_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_main_wrapper.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_profile_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_profits_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_questions_screen.dart';
import 'package:fahem/features/teacher/presentation/screens/teacher_statistics_screen.dart';
import 'package:fahem/features/teachers/presentation/screens/chat_screen.dart';
import 'package:fahem/features/teachers/presentation/screens/contact_teachers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes.dart';

class AppRouter {
  final AuthCubit _authCubit = AuthCubit();
  final AdminCubit _adminCubit = AdminCubit()..listenToPlatformLive();

  Map<String, dynamic> sampleTeacherData = {
    'id': '101', 'name': 'المهندس أبانوب', 'email': 'abanoub@fahem.com', 'phone': '0123456789', 'isActive': true, 'main_subject': 'برمجة', 'subjects': []
  };

  Map<String, dynamic> sampleStudentData = {
    'id': '101', 'name': 'يوسف أحمد', 'stage': 'الصف الثاني الابتدائي', 'phone': '01098765432', 'email': 'youssef@example.com', 'isActive': true, 'term': 'الترم الأول'
  };

  Route? generateRoute(RouteSettings settings) {
    // 👈 الإصلاح: كان الكود يحوّل (cast) أي arguments بالقوة لـ Map، فلو الراوت
    // مرسل لها arguments من نوع تاني (زي StudentCubit في ProfileScreen) كان
    // التطبيق يكره (Crash) فوراً قبل ما يدخل أصلاً على الـ switch. دلوقتي بنفحص
    // النوع الأول، ولو مش Map نسيبه null بدل ما نعمل throw.
    final args = settings.arguments is Map<String, dynamic>
        ? settings.arguments as Map<String, dynamic>
        : null;

    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.loginScreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(value: _authCubit, child: const LoginScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); 
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );

      case Routes.signUpScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _authCubit, child: const SignUpScreen()));

      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _authCubit, child: const ForgotPasswordScreen()));

      case Routes.HomeScreen:
        return MaterialPageRoute(builder: (_)=> const HomeScreen());

      case Routes.Courses:
        return MaterialPageRoute(builder: (_)=> const Courses());

      case Routes.SubjectDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => SubjectDetailsScreen(
            subjectId: args?['subjectId'] as String? ?? 'sci',
            subjectTitle: args?['subjectTitle'] as String? ?? 'مادة',
            studentTerm: args?['studentTerm'] as String? ?? 'الترم الأول',
          ),
        );

     case Routes.MainWrapper:
 return MaterialPageRoute(
   builder: (_) => BlocProvider(
     create: (context) => StudentCubit()..loadStudentDashboard(),
     child: const MainWrapper(),
   ),
 );
      case Routes.VideoPlayerScreen:
        return MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            lessonTitle: args?['lessonTitle'] as String? ?? '',
            videoUrl: args?['videoUrl'] as String? ?? '',
            questions: args?['questions'] as List<dynamic>? ?? [],
            subjectId: args?['subjectId'] as String? ?? 'sci',
            studentTerm: args?['studentTerm'] as String? ?? 'الترم الأول',
          ),
        );

      case Routes.LessonSummaryScreen:
        return MaterialPageRoute(
          builder: (_) => LessonSummaryScreen(
            lessonTitle: args?['lessonTitle'] as String? ?? '',
            summaries: args?['summaries'] as List<dynamic>? ?? [],
          ),
        );

      case Routes.QuizScreen:
        return MaterialPageRoute(
          builder: (_) => QuizScreen(
            lessonTitle: args?['lessonTitle'] as String? ?? '',
            questions: args?['questions'] as List<dynamic>? ?? [],
            subjectId: args?['subjectId'] as String? ?? 'sci',
            studentTerm: args?['studentTerm'] as String? ?? 'الترم الأول',
          ),
        );

      case Routes.ProfileScreen: 
        // 👈 فحص أمان إضافي: لو حصل واتنقل لشاشة البروفيل من غير ما يبعت StudentCubit
        // (أو بعت نوع غلط)، منعمل Cubit جديد ونحمل الداشبورد فيه بدل ما نكره التطبيق.
        final studentCubit = settings.arguments is StudentCubit
            ? settings.arguments as StudentCubit
            : (StudentCubit()..loadStudentDashboard());
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: studentCubit, child: const ProfileScreen()));

      case Routes.ContactTeachersScreen:
        return MaterialPageRoute(builder: (_)=> const ContactTeachersScreen());

      case Routes.ChatScreen: 
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            teacherName: args?['teacherName'] as String? ?? 'المعلم',
            subject: args?['subject'] as String? ?? 'المادة',
          ),
        );

      case Routes.PerformanceScreen:
        return MaterialPageRoute(builder: (_)=> const PerformanceScreen());

      case Routes.OtpVerificationScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _authCubit,
            child: OtpVerificationScreen(email: args?['email'] ?? 'تحت المعالجة', uid: args?['uid'] ?? ''),
          ),
        );

      case Routes.RoleSelectionScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _authCubit, child: const RoleSelectionScreen()));
      
      case Routes.ParentWrapper:
        return MaterialPageRoute(builder: (_)=> const ParentWrapper());

      case Routes.ParentHomeScreen:
        return MaterialPageRoute(builder: (_)=> const ParentHomeScreen());

      case Routes.LinkChildScreen:
        return MaterialPageRoute(builder: (_)=> LinkChildScreen(onTabSwitch: args?['onTabSwitch'] ?? (int i){} ));

      case Routes.ChildReportScreen:
        return MaterialPageRoute(
          builder: (_)=> ChildReportScreen(
            childrenData: args?['childrenData'] as List<Map<String, dynamic>>? ?? [],
            initialChild: args?['initialChild'] as Map<String, dynamic>?,
          )
        );

      case Routes.PaymentCheckoutScreen:
        return MaterialPageRoute(
          builder: (_)=> PaymentCheckoutScreen(
            packageAmount: args?['packageAmount'] as double? ?? 100.0,
            onTabSwitch: args?['onTabSwitch'] ?? (int i){},
          )
        );

      case Routes.ParentProfileScreen:
        return MaterialPageRoute(builder: (_)=> const ParentProfileScreen());

      case Routes.TeacherSubjectsTab:
        return MaterialPageRoute(builder: (_)=> const TeacherSubjectsTab());

      case Routes.TeacherMainWrapper:
        return MaterialPageRoute(builder: (_)=> const TeacherMainWrapper());

      case Routes.AddLessonContentScreen:
        return MaterialPageRoute(builder: (_)=> const AddLessonContentScreen(lessonName: "Lesson 1", contentType: "video"));

      case Routes.LessonContentViewScreen:
        return MaterialPageRoute(builder: (_)=> const AddLessonContentScreen(lessonName: "Lesson 1", contentType: "video"));

      case Routes.ManageMediaContentScreen:
        return MaterialPageRoute(builder: (_)=> ManageMediaContentScreen(
          lessonName: args?['lessonName'] as String? ?? '',
          initialContent: args?['initialContent'] as String?,
        ));

      case Routes.ManageTextSummaryScreen:
        return MaterialPageRoute(builder: (_)=> ManageTextSummaryScreen(
          lessonName: args?['lessonName'] as String? ?? '',
          initialSummary: args?['initialSummary'] as String?,
        ));

      case Routes.ManageQuizContentScreen:
        return MaterialPageRoute(builder: (_)=> ManageQuizContentScreen(
          lessonName: args?['lessonName'] as String? ?? '',
          unitName: args?['unitName'] as String? ?? 'الوحدة الأولى',
          subjectId: args?['subjectId'] as String? ?? 'sci',
          term: args?['term'] as String? ?? 'الترم الثاني',
          initialQuestions: args?['initialQuestions'] as List<dynamic>?,
        ));

      case Routes.TeacherQuizEditorScreen:
        return MaterialPageRoute(builder: (_)=> TeacherQuizEditorScreen(
          lessonName: args?['lessonName'] as String? ?? '',
          initialQuestions: args?['initialQuestions'] as List<dynamic>?,
        ));

      case Routes.LessonContentHubScreen:
        return MaterialPageRoute(builder: (_)=> LessonContentHubScreen(
          lessonName: args?['lessonName'] as String? ?? '',
          unitName: args?['unitName'] as String? ?? 'الوحدة الأولى',
          stageName: args?['stageName'] as String? ?? 'المرحلة الدراسية',
          subjectId: args?['subjectId'] as String? ?? 'sci',
          term: args?['term'] as String? ?? 'الترم الثاني',
        ));

      case Routes.TeacherProfileScreen:
        return MaterialPageRoute(builder: (_)=> const TeacherProfileScreen());

      case Routes.TeacherUnitsScreen:
        return MaterialPageRoute(
          builder: (_) => TeacherUnitsScreen(
            stageName: args?['stageName'] as String? ?? 'الصف الرابع الابتدائي',
            subjectId: args?['subjectId'] as String? ?? 'sci',
            term: args?['term'] as String? ?? 'الترم الثاني',
          ),
        );

      case Routes.TeacherLessonsScreen:
        return MaterialPageRoute(
          builder: (_)=> TeacherLessonsScreen(
            unitName: args?['unitName'] as String? ?? 'الوحدة الأولى', 
            stageName: args?['stageName'] as String? ?? 'المرحلة الدراسية',
            subjectId: args?['subjectId'] as String? ?? 'sci',
            term: args?['term'] as String? ?? 'الترم الثاني',
          )
        );

      case Routes.TeacherStatisticsScreen:
        return MaterialPageRoute(builder: (_)=> const TeacherStatisticsScreen());

      case Routes.ResetPasswordScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _authCubit, child: const ResetPasswordScreen()));

      case Routes.TeacherQuestionsScreen:
        return MaterialPageRoute(builder: (_)=> const TeacherQuestionsScreen());

      case Routes.VerificationScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _authCubit, child: const VerificationScreen()));

      case Routes.TeacherFinancialScreen:
        return MaterialPageRoute(builder: (_)=> const TeacherFinancialScreen());

      // ─────────────────────────────────────────────
      // شاشات الإدارة المغلفة بـ AdminCubit
      // ─────────────────────────────────────────────
      case Routes.AdminMainWrapper:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: const AdminMainWrapper()));

      case Routes.AdminDashboardScreen:
        return MaterialPageRoute(builder: (_)=> BlocProvider.value(value: _adminCubit, child: const AdminDashboardScreen()));

      case Routes.AdminTeachersManagementScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: const AdminTeachersManagementScreen()));

      case Routes.AddTeacherScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: const AddTeacherScreen()));

      case Routes.EditTeacherScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: EditTeacherScreen(teacherData: args ?? sampleTeacherData)));

      case Routes.TeacherDetailsScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: TeacherDetailsScreen(teacherData: args ?? sampleTeacherData)));

      case Routes.AdminStudentsManagementScreen:
        return MaterialPageRoute(builder: (_)=> BlocProvider.value(value: _adminCubit, child: const AdminStudentsManagementScreen()));

      case Routes.EditStudentScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: EditStudentScreen(studentData: args ?? sampleStudentData)));

      case Routes.StudentDetailsScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: StudentDetailsScreen(studentData: args ?? sampleStudentData)));

      case Routes.AdminTreasuryScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: const AdminTreasuryScreen()));

      // 👈 تم إضافة مسارات أولياء الأمور هنا بشكل مؤمن
      case Routes.AdminParentsManagementScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: const AdminParentsManagementScreen()));

      case Routes.ParentDetailsScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: ParentDetailsScreen(parentData: args ?? {})));

      case Routes.EditParentScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider.value(value: _adminCubit, child: EditParentScreen(parentData: args ?? {})));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  void dispose() {
    _authCubit.close();
    _adminCubit.close();
  }
}