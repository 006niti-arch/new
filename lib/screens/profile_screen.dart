// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_sender/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in!");
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Plan'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Could not load user data."));
          }

          final userData = snapshot.data!.data()!;
          final email = userData['email'] ?? 'No email found';
          final planType = (userData['planType'] ?? 'free').toString();
          final expiryDate = (userData['planExpiryDate'] as Timestamp?)?.toDate();
          final bool isTrial = planType == 'trial';
          int daysLeft = 0;
          bool hasExpired = false;

          if (expiryDate != null) {
            final difference = expiryDate.difference(DateTime.now());
            daysLeft = difference.inDays;
            if (difference.isNegative) {
              hasExpired = true;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_circle, size: 80, color: AppTheme.accentColor),
                      const SizedBox(height: 16),
                      Text(email, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      Text('Current Plan', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        planType.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                      ),
                      const SizedBox(height: 16),
                      
                      if (isTrial)
                        if (hasExpired)
                          Text(
                            'Your trial has expired.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            'You have ${daysLeft + 1} days left in your trial.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                      else if (expiryDate != null)
                        Text(
                          'Expires on: ${DateFormat.yMMMd().format(expiryDate)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upgrade functionality coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.star_border),
                        label: const Text('Upgrade Plan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}