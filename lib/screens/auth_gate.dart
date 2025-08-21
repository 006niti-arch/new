// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_sender/screens/home_screen.dart';
import 'package:whatsapp_sender/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens for changes in the authentication state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the stream is still loading, show a progress indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // If a user is logged in (snapshot has data)
        if (snapshot.hasData) {
          return const HomeScreen(); // Go to the main app screen
        }
        
        // If no user is logged in
        return const LoginScreen(); // Go to the login screen
      },
    );
  }
}