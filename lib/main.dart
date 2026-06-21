import 'package:fahem/core/routing/app_router.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:fahem/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(
    MultiBlocProvider(
      providers: [

        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),

      ],

      child: MyApp(
        appRouter: AppRouter(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.splashScreen,
      onGenerateRoute: appRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}