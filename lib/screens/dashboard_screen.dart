// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/overview_page.dart';
import '../pages/cpu_page.dart';
import '../pages/memory_page.dart';
import '../pages/info_page.dart';
import '../services/cpu_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Define tab-specific colors
  final List<Color> _tabColors = [
    AppTheme.primaryDark,  // Overview tab - blue
    AppTheme.success,      // CPU tab - green
    AppTheme.warning,      // Memory tab - amber
    AppTheme.info,         // Info tab - red
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          children: [
            Icon(
              Icons.dashboard_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('System Monitor Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(cpuProvider.isMonitoring ? Icons.pause : Icons.play_arrow),
            tooltip: cpuProvider.isMonitoring ? 'Pause Monitoring' : 'Start Monitoring',
            onPressed: () {
              cpuProvider.isMonitoring 
                ? cpuProvider.stopMonitoring() 
                : cpuProvider.startMonitoring();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              // Add refresh functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
            },
          ),
          const SizedBox(width: 8),
          // Theme toggle button
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => _toggleTheme(context),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Listen to tab changes to update the UI
          ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) {
              final currentTabColor = _tabColors[_tabController.index];
              
              return Container(
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: currentTabColor.withOpacity(0.1),
                      border: Border.all(
                        color: currentTabColor,
                        width: 1,
                      ),
                    ),
                    labelColor: _tabColors[_tabController.index],
                    unselectedLabelColor: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    tabs: [
                      _buildTab(Icons.dashboard_outlined, 'Overview', _tabColors[0], _tabController.index == 0),
                      _buildTab(Icons.memory_outlined, 'CPU', _tabColors[1], _tabController.index == 1),
                      _buildTab(Icons.storage_outlined, 'Memory', _tabColors[2], _tabController.index == 2),
                      _buildTab(Icons.info_outline_rounded, 'Info', _tabColors[3], _tabController.index == 3),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Overview Tab
                OverviewPage(),
                
                // CPU Tab
                CpuPage(),
                
                // Memory Tab
                MemoryPage(),
                
                // Info Tab
                InfoPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Toggle theme method
  void _toggleTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
    
    // Show a snackbar to confirm theme change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${themeProvider.isDarkMode ? 'Dark' : 'Light'} Mode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Custom tab widget with color based on tab
  Widget _buildTab(IconData icon, String label, Color color, bool isSelected) {
    return Tab(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 18,
            color: isSelected ? color : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: isSelected 
              ? TextStyle(color: color) 
              : null,
          ),
        ],
      ),
    );
  }
}