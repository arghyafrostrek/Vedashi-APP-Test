import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VedashiApp()));
}

class VedashiApp extends StatelessWidget {
  const VedashiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => Scaffold(
          backgroundColor: const Color(0xFF1A3A1A),
          body: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco_rounded, size: 64, color: Color(0xFF91CA35)),
              const SizedBox(height: 16),
              const Text('Login Screen', style: TextStyle(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 8),
              Text('App is working!', style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          )),
        ),
        '/main': (_) => const Scaffold(body: Center(child: Text('Home'))),
      },
    );
  }
}
