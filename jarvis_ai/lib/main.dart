import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/onboarding.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/chat.dart';
import 'screens/voice.dart';
import 'screens/explore.dart';

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
      path: '/login',
      builder: (context, state) => const LoginScreen(),
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
    GoRoute(
      path: '/explore',
      builder: (context, state) => ExploreScreen(),
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
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
          primary: const Color(0xFF8B5CF6),
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
