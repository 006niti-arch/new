// lib/screens/results_screen.dart

import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final List<String> successfulNumbers;
  final List<String> failedNumbers;

  const ResultsScreen({
    super.key,
    required this.successfulNumbers,
    required this.failedNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sending Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Section for successful sends
            const Text(
              '✅ Successful Numbers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Text('(WhatsApp opened for these numbers)'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                // Display each successful number on a new line
                children: successfulNumbers.map((number) => ListTile(title: Text(number))).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // Section for failed sends
            const Text(
              '❌ Failed Numbers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Text('(Could not open WhatsApp for these numbers)'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                // Display each failed number on a new line
                children: failedNumbers.map((number) => ListTile(title: Text(number))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}