import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Foundation import used above already covers kIsWeb and PointerDeviceKind

import 'package:provider/provider.dart';
import 'package:startap/providers/auth_provider.dart';
import 'package:startap/providers/onboarding_provider.dart';
import 'package:startap/providers/profile_provider.dart';
import 'package:startap/providers/user_provider.dart';
import 'package:startap/providers/ai_coach_provider.dart';
import 'package:startap/providers/nutrition_provider.dart';
import 'package:startap/providers/workout_provider.dart';
import 'package:startap/providers/health_provider.dart';
import 'package:startap/screens/auth/login_screen.dart';
import 'package:startap/screens/onboarding/onboarding_router.dart';

import 'package:startap/services/profile_api.dart';
import 'screens/home/home_screen.dart';

import 'firebase_options.dart';

// custom scroll behavior allowing both touch and mouse input; useful on web/mobile
class _WebTouchScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();           
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,   
  );

  
  
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AICoachProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(api: ProfileApi()),
        ),
      ],
      child: MaterialApp(
        title: 'AI Fitness Coach',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          // Если хотите убрать фиолетовый везде по приложению, поменяйте и эти два параметра:
          // primaryColor: const Color(0xFFFF4538),
          // colorScheme: const ColorScheme.dark(primary: Color(0xFFFF4538)),
          primaryColor: const Color(0xFF6C5CE7), // Оставил ваш, если он нужен
          scaffoldBackgroundColor: const Color(0xFF0A0E21),
          
          // 👇 ДОБАВЛЕНО: Настройка цвета курсора и выделения текста 👇
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFFFF4538),
            selectionColor: Color(0x66FF4538), // Полупрозрачный для выделения текста
            selectionHandleColor: Color(0xFFFF4538), // Цвет "капелек" при выделении
          ),
          // 👆 --------------------------------------------------- 👆
        ),
        builder: (context, widget) {
          // wrap every route with scroll configuration to make
          // web + mobile scrolling smooth and respond to touch.
          return ScrollConfiguration(
            behavior: _WebTouchScrollBehavior(),
            child: widget ?? const SizedBox.shrink(),
          );
        },
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingRouter(),
        },
      ),

    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
