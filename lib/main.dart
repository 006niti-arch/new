// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsapp_sender/firebase_options.dart';
import 'package:whatsapp_sender/providers/campaign_provider.dart';
import 'package:whatsapp_sender/screens/auth_gate.dart';
import 'package:whatsapp_sender/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CampaignProvider(),
      child: MaterialApp(
        title: 'WA Sender Pro',
        theme: AppTheme.darkTheme, // Use the new dark theme!
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}