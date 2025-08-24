// lib/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatsapp_sender/l10n/app_localizations_manual.dart';
import 'package:whatsapp_sender/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _createUserDocument(User user, {bool isNewUser = false}) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    // Only create the document if the user is signing up for the very first time
    if (!docSnapshot.exists) {
      final expiryDate = DateTime.now().add(const Duration(days: 15));
      await userDoc.set({
        'email': user.email,
        'planType': 'trial',
        'planExpiryDate': Timestamp.fromDate(expiryDate),
        'stats': {'totalMessagesSent': 0, 'totalCampaignsSent': 0},
        'isNewUser': isNewUser, // THIS IS THE NEW, RELIABLE FLAG
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() { _errorMessage = null; _isGoogleLoading = true; });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // We check if this is the first time the user is signing in with Google
        bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        await _createUserDocument(userCredential.user!, isNewUser: isNewUser);
      }

    } catch (e) {
      setState(() { _errorMessage = "An error occurred with Google Sign-In. Please try again."; });
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() { _errorMessage = null; _isLoading = true; });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          await _createUserDocument(userCredential.user!, isNewUser: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = e.message; });
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The UI is correct and remains the same
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.rocket_launch_outlined, size: 80, color: AppTheme.accentColor),
                const SizedBox(height: 20),
                Text(
                  _isLogin 
                    ? AppLocalizationsManual.of(context).translate('loginWelcome') 
                    : AppLocalizationsManual.of(context).translate('createAccountTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? AppLocalizationsManual.of(context).translate('loginSubtitle') 
                    : AppLocalizationsManual.of(context).translate('createAccountSubtitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController, 
                  decoration: InputDecoration(labelText: AppLocalizationsManual.of(context).translate('emailAddress')), 
                  keyboardType: TextInputType.emailAddress
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController, 
                  decoration: InputDecoration(labelText: AppLocalizationsManual.of(context).translate('password')), 
                  obscureText: true
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.errorColor)),
                  ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit, 
                        child: Text(_isLogin 
                          ? AppLocalizationsManual.of(context).translate('login') 
                          : AppLocalizationsManual.of(context).translate('createAccount'))
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() { _isLogin = !_isLogin; _errorMessage = null; }),
                  child: Text(_isLogin ? 'First time here? Create Account' : 'Already have an account? Login'),
                ),
                 const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isGoogleLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset('assets/google_logo.png', height: 24.0),
                    label: const Text('Continue with Google'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}