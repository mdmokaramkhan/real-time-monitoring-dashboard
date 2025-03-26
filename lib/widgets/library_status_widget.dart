import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cpu_provider.dart';

class LibraryStatusWidget extends StatelessWidget {
  const LibraryStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final bool isNativeLibraryLoaded = cpuProvider.nativeLibraryLoaded;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isNativeLibraryLoaded ? Icons.check_circle : Icons.error,
                  color: isNativeLibraryLoaded ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Native Library Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isNativeLibraryLoaded
                  ? 'Using real system data'
                  : 'Using simulated data (Native library not loaded)',
              style: TextStyle(
                color: isNativeLibraryLoaded ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (!isNativeLibraryLoaded)
              const Text(
                'Make sure the native library is correctly built and placed in the right location.',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
} 