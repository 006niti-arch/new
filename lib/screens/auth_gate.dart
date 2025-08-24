// lib/screens/auth_gate.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_sender/screens/generic_info_screen.dart';
import 'package:whatsapp_sender/screens/home_screen.dart';
import 'package:whatsapp_sender/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasData) {
          return NewUserWelcomeCheck(user: snapshot.data!);
        }
        
        return const LoginScreen();
      },
    );
  }
}

class NewUserWelcomeCheck extends StatefulWidget {
  final User user;
  const NewUserWelcomeCheck({super.key, required this.user});

  @override
  State<NewUserWelcomeCheck> createState() => _NewUserWelcomeCheckState();
}

class _NewUserWelcomeCheckState extends State<NewUserWelcomeCheck> {
  @override
  void initState() {
    super.initState();
    _checkIfNewUserAndShowPopup();
  }

  void _checkIfNewUserAndShowPopup() async {
    // Give Firestore a moment to ensure the user document is created
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
    
    if (mounted && userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data['isNewUser'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAgreementDialog(context);
        });
      }
    }
  }

  // THIS IS THE NEW, REDESIGNED DIALOG
  void _showAgreementDialog(BuildContext context) {
    const String benefitsContent = """
**Your Account's Safety is Our #1 Priority.**

Most "fully automated" apps can get your account flagged and permanently blocked. Our approach is different. We keep you in control.

• **Human-Powered by Design:** By requiring you to press "send" for each message, our app ensures your activity always looks natural and human. This is the single most important feature to prevent your number from being banned.

• **No Dangerous Permissions:** We will never ask for invasive access to your phone's private data. Our app acts as a smart assistant, not a spy.

**Supercharge Your Workflow.**

Our app is the perfect bridge between tedious manual work and risky automation.

• **Effortless Campaign Setup:** Import hundreds of contacts in seconds from your phone's address book or a CSV/Excel file.

• **The Perfect Message, Every Time:** Write your message once, and our app will perfectly pre-fill it for every single contact in your campaign.

• **Smart, Controlled Sending:** Our intelligent timer automatically paces your messages, while the pause and resume feature gives you the flexibility to manage your campaigns on your schedule.
""";
    
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Welcome to WA Sender Pro!'),
          // The content is now a Column to hold multiple items
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Here's why our app is the smarter, safer choice:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 24),
                // This makes the benefits text scrollable if it's too long
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      benefitsContent.replaceAll('**', ''),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ),
                const Divider(height: 24),
                // The legal agreement text is at the bottom
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      const TextSpan(text: 'By clicking "Agree", you accept our '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const GenericInfoScreen(
                                title: 'Terms & Conditions', 
                                content: 'Your full Terms & Conditions content goes here...'
                              ),
                            ));
                          },
                          child: Text('Terms of Service', style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline, fontSize: 12)),
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const GenericInfoScreen(
                                title: 'Privacy Policy', 
                                content: 'Your full Privacy Policy content goes here...'
                              ),
                            ));
                          },
                          child: Text('Privacy Policy', style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline, fontSize: 12)),
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Disagree'),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
            ElevatedButton(
              child: const Text('Agree & Continue'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .update({'isNewUser': false});
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}