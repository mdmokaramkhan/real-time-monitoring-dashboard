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
    AppTheme.info,          // Overview tab - blue
    AppTheme.success,       // CPU tab - green
    AppTheme.warning,       // Memory tab - amber
    AppTheme.primaryDark,   // Info tab - purple
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Listen for tab changes to update state
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Ensure the data is loaded when the dashboard initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cpuProvider = Provider.of<CpuProvider>(context, listen: false);
      
      // If not already monitoring, ensure it starts
      if (!cpuProvider.isMonitoring) {
        cpuProvider.startMonitoring();
      }
    });
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
    final Color currentColor = _tabColors[_tabController.index];
    
    return Scaffold(
      body: Column(
        children: [
          // Custom app bar with elevation and glassmorphism effect
          _buildAppBar(cpuProvider, themeProvider, currentColor, isDarkMode),
          
          // Main content area with navigation and content
          Expanded(
            child: Row(
              children: [
                // Left side navigation
                _buildSideNavigation(theme, currentColor),
                SizedBox(width: 10),
                // Main content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    CpuProvider cpuProvider, 
    ThemeProvider themeProvider,
    Color currentColor,
    bool isDarkMode,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: currentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  color: currentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'System Monitor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          
          const Spacer(),
          
          // Action buttons
          _buildMonitoringStatus(cpuProvider),
          const SizedBox(width: 16),
          
          // Play/Pause button
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: currentColor.withOpacity(0.1),
              padding: const EdgeInsets.all(10),
            ),
            icon: Icon(
              cpuProvider.isMonitoring ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: currentColor,
            ),
            tooltip: cpuProvider.isMonitoring ? 'Pause Monitoring' : 'Resume Monitoring',
            onPressed: () {
              cpuProvider.isMonitoring 
                ? cpuProvider.stopMonitoring() 
                : cpuProvider.startMonitoring();
            },
          ),
          
          const SizedBox(width: 8),
          
          // Theme toggle button
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              padding: const EdgeInsets.all(10),
            ),
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => _toggleTheme(context),
          ),
          
          const SizedBox(width: 8),
          
          // Settings button
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              padding: const EdgeInsets.all(10),
            ),
            icon: Icon(
              Icons.settings_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(ThemeData theme, Color currentColor) {
    return Container(
      width: 84,
      margin: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildNavItem(0, 'Overview', Icons.dashboard_outlined, Icons.dashboard_rounded),
          _buildNavItem(1, 'CPU', Icons.memory_outlined, Icons.memory_rounded),
          _buildNavItem(2, 'Memory', Icons.storage_outlined, Icons.storage_rounded),
          _buildNavItem(3, 'Info', Icons.info_outline_rounded, Icons.info_rounded),
          const Spacer(),
          // Version number at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData outlinedIcon, IconData filledIcon) {
    final isSelected = _tabController.index == index;
    final theme = Theme.of(context);
    final color = isSelected ? _tabColors[index] : theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _tabController.animateTo(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? _tabColors[index].withOpacity(0.1) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoringStatus(CpuProvider cpuProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cpuProvider.isMonitoring 
          ? AppTheme.success.withOpacity(0.1) 
          : AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cpuProvider.isMonitoring ? AppTheme.success.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cpuProvider.isMonitoring ? AppTheme.success : AppTheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            cpuProvider.isMonitoring ? 'Live Monitoring' : 'Monitoring Paused',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cpuProvider.isMonitoring ? AppTheme.success : AppTheme.error,
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
  }
}