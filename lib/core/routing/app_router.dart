import 'package:fahem/features/admin/data/teacher_model.dart';
import 'package:fahem/features/admin/presentation/screens/add_teacher_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_financials_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_main_wrapper.dart';
import 'package:fahem/features/admin/presentation/screens/admin_students_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/admin_teachers_management_screen.dart';
import 'package:fahem/features/admin/presentation/screens/edit_student_screen.dart';
import 'package:fahem/features/admin/presentation/screens/edit_teacheer_screen.dart';
import 'package:fahem/features/admin/presentation/screens/student_details_screen.dart';
import 'package:fahem/features/admin/presentation/screens/teacher_details_screen.dart';
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
import 'package:fahem/features/splash/presentation/screens/splash_screen.dart' hide TeacherModel;
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
// import '../../features/login/logic/auth_cubit.dart';
import 'routes.dart';

class AppRouter {
  final AuthCubit _authCubit = AuthCubit();

  Map<String, dynamic> sampleTeacherData = {
  'id': '101',
  'name': 'المهندس أبانوب مَلَك',
  'email': 'abanoub.malak@fahem.com',
  'phone': '0123456789',
  'isActive': true, // جرب تغيرها لـ false عشان تشوف شكل كارت "حساب موقوف"
  'main_subject': 'تكنولوجيا المعلومات والبرمجة',
};

Map<String, dynamic> sampleStudentData = {
  'id': '101',
  'name': 'يوسف أحمد علي',
  'stage': 'الصف الثاني الابتدائي',
  'phone': '01098765432',
  'email': 'youssef.ahmed@example.com',
  'isActive': true, // جرب تغييرها لـ false لرؤية حالة "حساب موقوف"
  'enrolled_count': 4, // عدد الدورات
  'exams_count': 18,   // عدد الامتحانات
  // يمكنك إضافة قائمة الدورات هنا إذا قمت بتعديل الـ Widget لتستقبل القائمة
};

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.loginScreen:
        return PageRouteBuilder(
          // 1. تغليف الشاشة بالـ Provider الموحد أولاً
          pageBuilder: (context, animation, secondaryAnimation) =>
              BlocProvider.value(value: _authCubit, child: const LoginScreen()),
          // 2. تطبيق الأنيميشن الخاص بك (Slide من اليمين)
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // من اليمين إلى اليسار
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );

      // case Routes.signUpScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: _authCubit,
      //       child: const SignUpScreen(),
      //     ),
      //   );


      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _authCubit, // 👈 مشاركة نفس الـ Cubit
            child: const SignUpScreen(),
          ),
        );

      // case Routes.forgotPasswordScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: _authCubit, // مشاركة نفس الـ Cubit مع استعادة كلمة المرور
      //       child: const ForgotPasswordScreen(),
      //     ),
      //   );


      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _authCubit, 
            child: const ForgotPasswordScreen(),
          ),
        );

        case Routes.HomeScreen:
          return MaterialPageRoute(
            builder: (_)=>const HomeScreen()
          );

          case Routes.Courses:
          return MaterialPageRoute(
            builder: (_)=> Courses()
          );






  case Routes.SubjectDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SubjectDetailsScreen(
            subjectId: args['subjectId'] as String,
            subjectTitle: args['subjectTitle'] as String,
            studentTerm: args['studentTerm'] as String,
          ),
        );

          // case Routes.MainWrapper:
          // return MaterialPageRoute(
          //   builder: (_)=> MainWrapper()
          // );

                  case Routes.MainWrapper:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => StudentCubit()..loadStudentDashboard(),
              child: const MainWrapper(),
            ),
          );

          // case Routes.VideoPlayerScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> VideoPlayerScreen(lessonTitle: "Lesson 1")
          // );

// ==================== 2. مسار شاشة مشغل الفيديو ====================
      case Routes.VideoPlayerScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            lessonTitle: args['lessonTitle'] as String,
            videoUrl: args['videoUrl'] as String,
            questions: args['questions'] as List<dynamic>,
            subjectId: args['subjectId'] as String,
            studentTerm: args['studentTerm'] as String,
          ),
        );

          // case Routes.LessonSummaryScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> LessonSummaryScreen(lessonTitle: "Lesson 1")
          // );


        //   case Routes.LessonSummaryScreen:
        // final args = settings.arguments as Map<String, dynamic>;
        // return MaterialPageRoute(
        //   builder: (_) => LessonSummaryScreen(
        //     lessonTitle: args['lessonTitle'] as String,
        //     // يمكنك تمرير الملخصات هنا أيضاً لو أضفت حقل summary في الفايرستور
        //   ),
        // );




        case Routes.LessonSummaryScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LessonSummaryScreen(
            lessonTitle: args['lessonTitle'] as String,
            summaries: args['summaries'] as List<dynamic>,
          ),
        );

          // case Routes.QuizScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> QuizScreen(lessonTitle: "Lesson 1")
          // );

         case Routes.QuizScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuizScreen(
            lessonTitle: args['lessonTitle'] as String,
            questions: args['questions'] as List<dynamic>,
            subjectId: args['subjectId'] as String,
            studentTerm: args['studentTerm'] as String,
          ),
        );

          // case Routes.ProfileScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> ProfileScreen()
          // );

          case Routes.ProfileScreen: // تأكد من مطابقة الاسم لكلاس الـ Routes عندك
        // سحب نسخة الكوبيت الممررة في أمر الانتقال 🛰️
        final studentCubit = settings.arguments as StudentCubit;
        
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: studentCubit, // تمرير نفس العقل النشط لشاشة التعديل 👈
            child: const ProfileScreen(),
          ),
        );

          case Routes.ContactTeachersScreen:
          return MaterialPageRoute(
            builder: (_)=> ContactTeachersScreen()
          );

         case Routes.ChatScreen: // 👈 تأكد من تطابق الاسم مع routes.dart
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => ChatScreen(
      teacherName: args['teacherName'] as String,
      subject: args['subject'] as String,
    ),
  );

          case Routes.PerformanceScreen:
          return MaterialPageRoute(
            builder: (_)=> PerformanceScreen()
          );

          // case Routes.OtpVerificationScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> OtpVerificationScreen(email: "aaaaa",)
          // );


        //   case Routes.OtpVerificationScreen:
        // // استقبال الحجج والداتا ديناميكياً من الشاشة السابقة 👈
        // final args = settings.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(
        //   builder: (_) => BlocProvider.value(
        //     value: _authCubit,
        //     child: OtpVerificationScreen(
        //       email: args?['email'] ?? 'تحت المعالجة',
        //       uid: args?['uid'] ?? '',
        //     ),
        //   ),
        // );



        // استبدل كيس الـ OtpVerificationScreen القديمة بالكود الديناميكي التالي:
        // case Routes.OtpVerificationScreen:
        //   final args = settings.arguments as Map<String, dynamic>?; // 👈 استقبال الداتا المحمية
        //   return MaterialPageRoute(
        //     builder: (_) => BlocProvider.value(
        //       value: _authCubit,
        //       child: OtpVerificationScreen(
        //         email: args?['email'] ?? 'تحت المعالجة',
        //         uid: args?['uid'] ?? '', // 👈 تمرير الـ UID الحقيقي لربط الفايرستور
        //       ),
        //     ),
        //   );





        // تأكد من تعديل الـ Case الثالثة داخل ملف الـ app_router.dart لتطابق الكود التالي:
          case Routes.OtpVerificationScreen:
            final args = settings.arguments as Map<String, dynamic>?; // استقبال البيانات الآمنة
            return MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: _authCubit,
                child: OtpVerificationScreen(
                  email: args?['email'] ?? 'تحت المعالجة',
                  uid: args?['uid'] ?? '', // تمرير الـ UID الحقيقي للسيرفر
                ),
              ),
            );

          // case Routes.RoleSelectionScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> RoleSelectionScreen()
          // );


          case Routes.RoleSelectionScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _authCubit, // 👈 حقن نفس الكائن لحفظ البيانات المؤقتة
            child: const RoleSelectionScreen(),
          ),
        );

          case Routes.ParentHomeScreen:
          return MaterialPageRoute(
            builder: (_)=> ParentHomeScreen()
          );

          case Routes.LinkChildScreen:
          return MaterialPageRoute(
            builder: (_)=> LinkChildScreen()
          );

          case Routes.ChildReportScreen:
          return MaterialPageRoute(
            builder: (_)=> ChildReportScreen(children: [
    ChildProfile(name: 'أحمد', stage: 'الصف الرابع'),
    ChildProfile(name: 'مريم', stage: 'الصف الثاني'),
  ],)
          );

          case Routes.PaymentCheckoutScreen:
          return MaterialPageRoute(
            builder: (_)=> PaymentCheckoutScreen(packageAmount: 100,children: ["Abanoub","Mian"])
          );

        case Routes.ParentProfileScreen:
          return MaterialPageRoute(
            builder: (_)=> ParentProfileScreen()
          );

          case Routes.TeacherSubjectsTab:
          return MaterialPageRoute(
            builder: (_)=> TeacherSubjectsTab()
          );

          case Routes.TeacherMainWrapper:
          return MaterialPageRoute(
            builder: (_)=> TeacherMainWrapper()
          );

          case Routes.AddLessonContentScreen:
          return MaterialPageRoute(
            builder: (_)=> AddLessonContentScreen(lessonName: "Lesson 1",contentType: "video",)
          );

          case Routes.LessonContentViewScreen:
          return MaterialPageRoute(
            builder: (_)=> AddLessonContentScreen(lessonName: "Lesson 1",contentType: "video",)
          );

          case Routes.ManageMediaContentScreen:
          return MaterialPageRoute(
            builder: (_)=> ManageMediaContentScreen(lessonName: "Lesson 1",initialContent: "video",)
          );

          case Routes.ManageTextSummaryScreen:
          return MaterialPageRoute(
            builder: (_)=> ManageTextSummaryScreen(lessonName: "Lesson 1",initialSummary: "summary",)
          );

          case Routes.ManageQuizContentScreen:
          return MaterialPageRoute(
            builder: (_)=> ManageQuizContentScreen(lessonName: "Lesson 1",initialQuestions: [])
          );

          case Routes.TeacherQuizEditorScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherQuizEditorScreen(lessonName: "Lesson 1")
          );

          case Routes.LessonContentHubScreen:
          return MaterialPageRoute(
            builder: (_)=> LessonContentHubScreen(lessonName: "Lesson 1")
          );

          case Routes.TeacherProfileScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherProfileScreen()
          );

          case Routes.TeacherUnitsScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherUnitsScreen(stageName: "الوحدة الثالثة",)
          );

          case Routes.TeacherLessonsScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherLessonsScreen(unitName:"الوحدى ال22",stageName: "الصف الرابع",)
          );

          case Routes.TeacherStatisticsScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherStatisticsScreen()
          );

          // case Routes.TeacherProfitsScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> TeacherProfitsScreen()
          // );


          case Routes.AdminTreasuryScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherQuestionsScreen()
          );


          case Routes.ResetPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _authCubit, // 👈 حقن نفس الـ Cubit لشاشة التعيين الجديدة
            child: const ResetPasswordScreen(),
          ),
        );




          case Routes.TeacherQuestionsScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherQuestionsScreen()
          );

          case Routes.AdminMainWrapper:
          return MaterialPageRoute(
            builder: (_)=> AdminMainWrapper()
          );

          case Routes.AdminDashboardScreen:
          return MaterialPageRoute(
            builder: (_)=> AdminDashboardScreen()
          );

          case Routes.AdminTeachersManagementScreen:
          return MaterialPageRoute(
            builder: (_)=> AdminTeachersManagementScreen()
          );

          case Routes.AddTeacherScreen:
          return MaterialPageRoute(
            builder: (_)=> AddTeacherScreen()
          );

          case Routes.EditTeacherScreen:
          return MaterialPageRoute(
            builder: (_)=> EditTeacherScreen(teacherData: sampleTeacherData,)
          );



          case Routes.TeacherDetailsScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherDetailsScreen(teacherData: sampleTeacherData,)
          );

          case Routes.AdminStudentsManagementScreen:
          return MaterialPageRoute(
            builder: (_)=> AdminStudentsManagementScreen()
          );


          case Routes.StudentDetailsScreen:
          return MaterialPageRoute(
            builder: (_)=> StudentDetailsScreen(studentData: sampleStudentData,)
          );

          case Routes.EditStudentScreen:
          return MaterialPageRoute(
            builder: (_)=> EditStudentScreen(studentData: sampleStudentData,)
          );


          
          // case Routes.VerificationScreen:
          // return MaterialPageRoute(
          //   builder: (_)=> VerificationScreen()
          // );


          case Routes.VerificationScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _authCubit, // 👈 حقن نفس الـ Cubit لشاشة التحقق
            child: const VerificationScreen(),
          ),
        );

          case Routes.ParentWrapper:
          return MaterialPageRoute(
            builder: (_)=> ParentWrapper()
          );


          case Routes.TeacherFinancialScreen:
          return MaterialPageRoute(
            builder: (_)=> TeacherFinancialScreen()
          );




      


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
  }
}

class TeacherDashboardScreen {
}
