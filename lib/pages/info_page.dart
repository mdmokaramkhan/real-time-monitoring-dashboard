import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Information',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed system information and specifications',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // System Information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'System Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Operating System: macOS Monterey 12.6'),
                    SizedBox(height: 8),
                    Text('System Model: MacBook Pro (2021)'),
                    SizedBox(height: 8),
                    Text('Processor: Apple M1 Pro'),
                    SizedBox(height: 8),
                    Text('RAM: 16 GB'),
                    SizedBox(height: 8),
                    Text('Storage: 512 GB SSD'),
                    SizedBox(height: 16),
                    Text(
                      'Network Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('IP Address: 192.168.1.100'),
                    SizedBox(height: 8),
                    Text('MAC Address: 00:11:22:33:44:55'),
                    SizedBox(height: 8),
                    Text('Network Interface: Wi-Fi'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
