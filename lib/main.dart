import 'package:fahem/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import 'package:fahem/features/login/presentation/screens/login.dart';
import 'package:fahem/features/sign_up/presentation/screens/sign_up.dart';
import 'package:fahem/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState()=>_MyAppState();
}

class _MyAppState extends State<MyApp>{

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:SplashScreen()
      
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