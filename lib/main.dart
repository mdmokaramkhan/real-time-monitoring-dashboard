import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/screens/dashboard_screen.dart';
import 'package:real_time_monitoring_dashboard/services/cpu_provider.dart';
import 'package:real_time_monitoring_dashboard/services/theme_provider.dart';
import 'package:real_time_monitoring_dashboard/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CpuProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'CPU Monitoring Dashboard',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const DashboardScreen(),
    );
  }
}