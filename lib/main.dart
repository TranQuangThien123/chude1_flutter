import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'presentation/pages/main_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReactiveMarketApp());
}

class ReactiveMarketApp extends StatelessWidget {
  const ReactiveMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chuyên đề 02: Reactive Streams & Asynchronous Dart',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.bearish,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardColor: AppColors.surface,
      ),
      home: const MainDashboardScreen(),
    );
  }
}
