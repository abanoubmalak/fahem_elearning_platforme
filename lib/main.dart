import 'package:fahem/core/routing/app_router.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp(appRouter: AppRouter(),));
}

class MyApp extends StatelessWidget{
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: Routes.splashScreen,
      onGenerateRoute: appRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      
      
    );
  }
}

// lib/
// ├── main.dart            # نقطة البداية وإعدادات التطبيق
// ├── app.dart             # إعداد الـ MaterialApp والـ Themes
// ├── core/                # الأشياء المشتركة التي لا تتغير بتغير الميزات
// │   ├── constants/       # ألوان التطبيق (primaryColor)، الروابط (API_URL)
// │   ├── errors/          # التعامل مع الاستثناءات (Exceptions)
// │   ├── theme/           # ملفات الـ Light & Dark Mode
// │   ├── utils/           # دوال مساعدة (تحويل التاريخ، التحقق من الإيميل)
// │   └── common_widgets/  # أزرار أو حقول نصية تُستخدم في كل التطبيق
// │
// ├── features/            # كل ميزة (Feature) في مجلد مستقل
// │   ├── auth/            # نظام التسجيل والدخول (طالب/معلم/ولي أمر)
// │   ├── splash/          # شاشة البداية (التي صممنا خلفيتها)
// │   ├── learning_path/   # خريطة المنهج (شاشة الطالب الرئيسية)
// │   ├── lesson_player/   # مشغل الدروس والفيديو
// │   ├── ai_tutor/        # شات الذكاء الاصطناعي (فهيم)
// │   ├── quiz/            # نظام الاختبارات والجيميفيكيشن
// │   └── parent_control/  # لوحة تحكم ولي الأمر
// │
// └── data/                # التعامل مع البيانات (الخارجية)
//     ├── models/          # تحويل الـ JSON إلى Objects (StudentModel, QuizModel)
//     ├── repositories/    # حلقة الوصل بين الداتا والواجهات
//     └── sources/         # الاتصال بـ Firebase أو API