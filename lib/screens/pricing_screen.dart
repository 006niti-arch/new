// lib/screens/pricing_screen.dart
import 'package:flutter/material.dart';
import 'package:whatsapp_sender/theme/app_theme.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Plans'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _PricingCard(
              planName: 'Monthly',
              price: '₹499',
              period: '/month',
              features: const [
                'Unlimited Campaigns', 'Unlimited Messages',
                'Downloadable Reports', 'Priority Support',
              ],
              isPopular: true,
            ),
            _PricingCard(
              planName: 'Yearly',
              price: '₹4,999',
              period: '/year',
              features: const [
                'All Monthly Features', 'Save 15% with Annual Billing',
                'Early Access to New Features',
              ],
            ),
            _PricingCard(
              planName: 'Lifetime',
              price: '₹14,999',
              period: 'one-time',
              features: const [
                'All Yearly Features', 'Pay Once, Use Forever',
                'Dedicated Account Manager',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String planName;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  const _PricingCard({
    required this.planName,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isPopular ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? const BorderSide(color: AppTheme.accentColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(planName, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppTheme.accentColor)),
                const SizedBox(width: 4),
                Text(period, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(height: 32),
            ...features.map((feature) => ListTile(
              leading: const Icon(Icons.check_circle, color: AppTheme.accentColor),
              title: Text(feature),
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact support to upgrade your plan.')),
                );
              },
              child: const Text('Contact to Upgrade'),
            ),
          ],
        ),
      ),
    );
  }
}