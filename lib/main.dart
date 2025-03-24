import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io' show Platform, Directory, File;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/screens/dashboard_screen.dart';
import 'package:real_time_monitoring_dashboard/services/cpu_provider.dart';
import 'package:real_time_monitoring_dashboard/theme/app_theme.dart';

void main() {
  late final DynamicLibrary nativeCpuLib;
  try {
    final List<String> searchPaths = [
      path.join('assets', 'native', 'libnative_cpu_lib.dll'),
      path.join('build', 'libs', 'cpu_monitor.dll'),
      path.join('native', 'build', 'Release', 'native_cpu_lib.dll'),
    ];

    String? libraryPath;
    for (final searchPath in searchPaths) {
      final fullPath = path.join(Directory.current.path, searchPath);
      print('Checking library at: $fullPath');
      if (File(fullPath).existsSync()) {
        libraryPath = fullPath;
        break;
      }
    }

    if (libraryPath == null) {
      throw Exception('Could not find native library in any of the search paths');
    }

    print('Loading library from: $libraryPath');
    nativeCpuLib = DynamicLibrary.open(libraryPath);
  } catch (e, stackTrace) {
    print('Failed to load native library: $e');
    print('Stack trace: $stackTrace');
    return;
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => CpuProvider(nativeCpuLib: nativeCpuLib),
      child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPU Monitoring Dashboard',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}