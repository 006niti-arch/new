// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_sender/screens/generic_info_screen.dart';
import 'package:whatsapp_sender/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper function to create styled list tiles
  Widget _buildListTile(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Placeholder content for policies
  final String _loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ... (Your content here)";

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
            icon: Icons.workspace_premium_outlined,
            title: 'Plan Details',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.menu_book_outlined,
            title: 'User Manual',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const GenericInfoScreen(
                  title: 'User Manual',
                  content: '1. Create a campaign...\n2. Upload your file...\n3. Start sending!', // Replace with your full manual
                ),
              ));
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.email_outlined,
            title: 'Contact Us',
            onTap: () async {
              final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'contact@example.com');
              await launchUrl(emailLaunchUri);
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.support_agent_outlined,
            title: 'Support',
            onTap: () async {
              final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'support@example.com');
              await launchUrl(emailLaunchUri);
            },
          ),
          
          // Section for legal information
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
                builder: (context) => GenericInfoScreen(title: 'Terms & Conditions', content: _loremIpsum),
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
                builder: (context) => GenericInfoScreen(title: 'Privacy Policy', content: _loremIpsum),
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
                builder: (context) => GenericInfoScreen(title: 'Refund Policy', content: _loremIpsum),
              ));
            },
          ),
        ],
      ),
    );
  }
}