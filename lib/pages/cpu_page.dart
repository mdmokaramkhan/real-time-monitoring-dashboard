import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/widgets/cpu_chart.dart';
import '../services/cpu_provider.dart';

class CpuPage extends StatelessWidget {
  const CpuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CpuProvider>(context);
    final stats = provider.stats;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CPU Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed CPU information and performance metrics',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // CPU detailed information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current CPU Usage',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('CPU Usage: ${stats.cpuString}'),
                    const SizedBox(height: 8),
                    const Text('CPU Model: Intel Core i7 (placeholder)'),
                    const SizedBox(height: 8),
                    const Text('CPU Cores: 8 (placeholder)'),
                    const SizedBox(height: 8),
                    const Text('CPU Clock Speed: 3.6 GHz (placeholder)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // CPU Chart (reusing the existing widget)
            const SizedBox(
              height: 400,
              child: CpuChartCard(),
            ),
          ],
        ),
      ),
    );
  }
}
