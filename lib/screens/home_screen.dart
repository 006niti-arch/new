// lib/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:whatsapp_sender/l10n/app_localizations_manual.dart';
import 'package:whatsapp_sender/providers/locale_provider.dart';
import 'package:whatsapp_sender/screens/campaign_history_screen.dart';
import 'package:whatsapp_sender/screens/contacts_importer_screen.dart';
import 'package:whatsapp_sender/screens/file_upload_screen.dart';
import 'package:whatsapp_sender/screens/manual_input_screen.dart';
import 'package:whatsapp_sender/screens/profile_screen.dart';
import 'package:whatsapp_sender/screens/settings_screen.dart';
import 'package:whatsapp_sender/screens/unsubscribe_screen.dart';
import 'package:whatsapp_sender/theme/app_theme.dart';

// --- Helper class for our Leveling System ---
class UserLevel {
  final int level;
  final String title;
  final int xpForNextLevel;
  final double progress;

  UserLevel({required this.level, required this.title, required this.xpForNextLevel, required this.progress});

  static UserLevel fromXp(int xp) {
    if (xp < 100) return UserLevel(level: 1, title: 'Novice Sender', xpForNextLevel: 100, progress: xp / 100);
    if (xp < 500) return UserLevel(level: 2, title: 'Campaigner', xpForNextLevel: 500, progress: xp / 500);
    if (xp < 1000) return UserLevel(level: 3, title: 'Pro Marketer', xpForNextLevel: 1000, progress: xp / 1000);
    return UserLevel(level: 4, title: 'Growth Hacker', xpForNextLevel: 5000, progress: xp / 5000);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This line makes the screen listen for language changes
    Provider.of<LocaleProvider>(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Not logged in.")));

    final userDocStream = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizationsManual.of(context).translate('missionControl')),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'My Plan',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Loading user data..."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final stats = data['stats'] as Map<String, dynamic>? ?? {};
          final totalMessages = stats['totalMessagesSent'] ?? 0;
          final totalCampaigns = stats['totalCampaignsSent'] ?? 0;
          final userLevel = UserLevel.fromXp(totalMessages);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _LevelProgressCard(user: user, userLevel: userLevel, totalMessages: totalMessages),
              const SizedBox(height: 16),
              _StatsGrid(totalCampaigns: totalCampaigns, totalMessages: totalMessages),
              const SizedBox(height: 24),
              _ActionCard(
                icon: Icons.contact_phone_outlined,
                title: AppLocalizationsManual.of(context).translate('homeImportContacts'),
                subtitle: AppLocalizationsManual.of(context).translate('homeImportContactsSubtitle'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsImporterScreen())),
              ),
              _ActionCard(
                icon: Icons.upload_file_outlined,
                title: AppLocalizationsManual.of(context).translate('homeCreateFromFile'),
                subtitle: AppLocalizationsManual.of(context).translate('homeCreateFromFileSubtitle'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FileUploadScreen())),
              ),
              _ActionCard(
                icon: Icons.edit_note,
                title: AppLocalizationsManual.of(context).translate('homeQuickSend'),
                subtitle: AppLocalizationsManual.of(context).translate('homeQuickSendSubtitle'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManualInputScreen())),
              ),
              _ActionCard(
                icon: Icons.history_edu,
                title: AppLocalizationsManual.of(context).translate('homeCampaignHistory'),
                subtitle: AppLocalizationsManual.of(context).translate('homeCampaignHistorySubtitle'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CampaignHistoryScreen())),
              ),
              _ActionCard(
                icon: Icons.block,
                title: AppLocalizationsManual.of(context).translate('homeManageUnsubscribes'),
                subtitle: AppLocalizationsManual.of(context).translate('homeManageUnsubscribesSubtitle'),
                iconColor: AppTheme.errorColor,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UnsubscribeScreen())),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- ALL HELPER WIDGETS ARE NOW INCLUDED ---

class _LevelProgressCard extends StatelessWidget {
  final User user;
  final UserLevel userLevel;
  final int totalMessages;

  const _LevelProgressCard({required this.user, required this.userLevel, required this.totalMessages});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email ?? 'Welcome!', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GradientText(
              userLevel.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
              colors: const [AppTheme.accentColor, Colors.tealAccent],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: userLevel.progress,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Lvl ${userLevel.level}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('$totalMessages / ${userLevel.xpForNextLevel} XP', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int totalCampaigns;
  final int totalMessages;

  const _StatsGrid({required this.totalCampaigns, required this.totalMessages});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(title: 'Campaigns Launched', value: totalCampaigns.toString(), icon: Icons.rocket_launch_outlined),
        _StatCard(title: 'Messages Sent', value: totalMessages.toString(), icon: Icons.send_outlined),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.accentColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineMedium),
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: iconColor ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}