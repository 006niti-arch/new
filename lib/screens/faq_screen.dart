// lib/screens/faq_screen.dart
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _FaqItem(
            question: 'How do I format my CSV or Excel file?',
            answer: 'Your file should have a single column. The first row should be a header (e.g., "PhoneNumber"), and every row after that should be one phone number. For the "Create New Campaign" option, make sure every number includes the country code (e.g., +919876543210).',
          ),
          _FaqItem(
            question: 'Why did my campaign stop sending?',
            answer: 'The campaign will automatically pause if you switch to another app or lock your screen. This is a safety feature to prevent your number from being banned. To continue, simply return to the app and the countdown will resume.',
          ),
          _FaqItem(
            question: 'Why do I have to press "send" for every message?',
            answer: 'This is the most important safety feature of the app. By requiring you to press "send" for each message, we ensure your activity looks human to WhatsApp, which drastically reduces the risk of your number being banned for bot-like activity.',
          ),
          _FaqItem(
            question: 'What happens if a number is not on WhatsApp?',
            answer: 'When the app tries to open a chat with a number that is not on WhatsApp, the WhatsApp application itself will show you an error message. Simply go back to our app, and the campaign will continue to the next number after the delay.',
          ),
        ],
      ),
    );
  }
}

// A reusable styled widget for FAQ items
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}