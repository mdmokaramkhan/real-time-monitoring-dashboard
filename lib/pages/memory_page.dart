import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/widgets/memory_chart.dart';
import '../services/cpu_provider.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

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
              'Memory Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed memory usage and performance metrics',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Memory detailed information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Memory Usage Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Memory Usage: ${stats.memoryString}'),
                    const SizedBox(height: 8),
                    Text('Total Memory: ${stats.memoryTotal.toStringAsFixed(2)} GB'),
                    const SizedBox(height: 8),
                    Text('Used Memory: ${stats.memoryUsed.toStringAsFixed(2)} GB'),
                    const SizedBox(height: 8),
                    const Text('Memory Type: DDR4 (placeholder)'),
                    const SizedBox(height: 8),
                    const Text('Memory Speed: 3200 MHz (placeholder)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Memory Chart (reusing the existing widget)
            const SizedBox(
              height: 400,
              child: MemoryChartCard(),
            ),
          ],
        ),
      ),
    );
  }
}
