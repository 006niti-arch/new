// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_sender/providers/locale_provider.dart';
import 'package:whatsapp_sender/screens/faq_screen.dart';
import 'package:whatsapp_sender/screens/generic_info_screen.dart';
import 'package:whatsapp_sender/screens/pricing_screen.dart';
import 'package:whatsapp_sender/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // --- ALL TEXT CONTENT IS NOW INCLUDED HERE ---

  final String whyChooseUsContent = """
In a world full of messaging tools, it’s easy to get lost in promises of full automation. But we built our app on a different, more important promise: your peace of mind.

Our app is for serious marketers and businesses who understand that their WhatsApp account is a valuable asset. You need a powerful tool that works with the system, not against it.

**1. Your Account's Safety is Our #1 Priority.**
By requiring you to press "send" for each message, our app ensures your activity always looks natural and human. This is the single most important feature to prevent your number from being banned.

**2. Supercharge Your Workflow.**
Our app is the perfect bridge between tedious manual work and risky automation, allowing you to manage campaigns and pre-fill messages effortlessly.
""";

  final String termsContent = """
**Terms & Conditions**

Last updated: August 23, 2025

By using our application (the "Service"), you agree to these terms. You are responsible for all activity on your account. You agree not to use the Service for any illegal purpose, for sending spam, or in any way that violates the terms of service of WhatsApp Inc. Misuse of the Service that results in your WhatsApp account being banned is your sole responsibility. We may terminate or suspend your account if you breach these Terms.
""";

  final String privacyContent = """
**Privacy Policy**

Last updated: August 23, 2025

We collect the information necessary to provide the Service, including your email address and any campaign data you provide (contact numbers, messages). This data is stored securely in your personal cloud database and is not sold to third parties. We use industry-standard security, but no method is 100% secure. You have the right to access or delete your data at any time.
""";

  final String eulaContent = "Your End-User License Agreement content goes here...";
  final String cookiePolicyContent = "Your Cookie Policy content goes here...";
  final String refundContent = "Your Refund Policy content goes here...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Information'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildListTile(
            context,
            icon: Icons.language_outlined,
            title: 'Change Language',
            onTap: () => _showLanguagePicker(context),
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.account_circle_outlined,
            title: 'My Profile & Plan',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.workspace_premium_outlined,
            title: 'Plan Details & Pricing',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PricingScreen()));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.shield_outlined,
            title: 'Why Choose Us?',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GenericInfoScreen(
                  title: 'Why Choose Us?',
                  content: whyChooseUsContent.replaceAll('**', ''),
                ),
              ));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.quiz_outlined,
            title: 'FAQ',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.support_agent_outlined,
            title: 'Support',
            onTap: () async {
              final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'support@example.com');
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Legal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildListTile(
            context,
            icon: Icons.gavel_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GenericInfoScreen(title: 'Terms & Conditions', content: termsContent.replaceAll('**', '')),
              ));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GenericInfoScreen(title: 'Privacy Policy', content: privacyContent.replaceAll('**', '')),
              ));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.description_outlined,
            title: 'EULA',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GenericInfoScreen(title: 'EULA', content: eulaContent),
              ));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.cookie_outlined,
            title: 'Cookie Policy',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GenericInfoScreen(title: 'Cookie Policy', content: cookiePolicyContent),
              ));
            },
          ),
           const Divider(),
          _buildListTile(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Refund Policy',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GenericInfoScreen(title: 'Refund Policy', content: refundContent),
              ));
            },
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<LocaleProvider>(context, listen: false);
        return AlertDialog(
          title: const Text('Change Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(locale: const Locale('en'), name: 'English', currentLocale: provider.locale),
              _LanguageOption(locale: const Locale('es'), name: 'Español (Spanish)', currentLocale: provider.locale),
              _LanguageOption(locale: const Locale('pt'), name: 'Português (Portuguese)', currentLocale: provider.locale),
              _LanguageOption(locale: const Locale('ar'), name: 'العربية (Arabic)', currentLocale: provider.locale),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String name;
  final Locale? currentLocale;

  const _LanguageOption({required this.locale, required this.name, this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final isSelected = currentLocale == null
        ? Localizations.localeOf(context).languageCode == locale.languageCode
        : currentLocale!.languageCode == locale.languageCode;

    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
      onTap: () {
        provider.setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }
}