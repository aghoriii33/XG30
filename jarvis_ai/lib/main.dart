import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/onboarding.dart';
import 'screens/home.dart';
import 'screens/chat.dart';
import 'screens/voice.dart';

void main() {
  runApp(
    const ProviderScope(
      child: JarvisAI(),
    ),
  );
}

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => ChatScreen(),
    ),
    GoRoute(
      path: '/voice',
      builder: (context, state) => const VoiceScreen(),
    ),
  ],
);

class JarvisAI extends StatelessWidget {
  const JarvisAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JARVIS AI',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07090E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
          primary: const Color(0xFF2563EB),
          background: const Color(0xFF07090E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C0E14),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      routerConfig: _router,
    );
  }
}
