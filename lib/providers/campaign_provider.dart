// lib/providers/campaign_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'; // Corrected Import
import 'package:firebase_auth/firebase_auth.dart';     // Corrected Import
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignProvider with ChangeNotifier {
  String _campaignName = '';
  List<String> _phoneNumbers = [];
  String _message = '';
  int _delayInSeconds = 20;
  bool _isRunning = false;
  bool _isPaused = false;
  int _currentIndex = 0;
  Timer? _timer;
  int _countdownSeconds = 0;
  String _planError = '';

  // Getters
  String get planError => _planError;
  int get countdownSeconds => _countdownSeconds;
  List<String> get phoneNumbers => _phoneNumbers;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  int get totalNumbers => _phoneNumbers.length;

  Future<bool> _isPlanActive() async {
    _planError = '';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _planError = "You are not logged in.";
      return false;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'planType': 'free',
          'planExpiryDate': null,
          'stats': {'totalMessagesSent': 0, 'totalCampaignsSent': 0}
        });
        return true;
      }
      final data = userDoc.data()!;
      final planType = data['planType'] as String?;
      final expiryDate = (data['planExpiryDate'] as Timestamp?)?.toDate();
      if (planType == 'lifetime') return true;
      if (planType == 'monthly' || planType == 'yearly') {
        if (expiryDate == null || expiryDate.isBefore(DateTime.now())) {
          _planError = "Your plan has expired. Please contact support.";
          return false;
        }
        return true;
      }
      return true;
    } catch (e) {
      _planError = "Could not verify your plan. Please try again.";
      return false;
    }
  }

  Future<void> setupCampaign({
    required String campaignName,
    required List<String> numbers,
    required String message,
    required int delay,
  }) async {
    if (!await _isPlanActive()) {
      notifyListeners();
      return;
    }
    final user = FirebaseAuth.instance.currentUser!;
    final unsubscribesSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('unsubscribes').get();
    final unsubscribedList = unsubscribesSnapshot.docs.map((doc) => doc.id).toSet();
    final filteredNumbers = numbers.where((num) => !unsubscribedList.contains(num)).toList();
    
    _campaignName = campaignName;
    _phoneNumbers = filteredNumbers;
    _message = message;
    _delayInSeconds = delay;
    _currentIndex = 0;
    _isRunning = true;
    _isPaused = false;
    notifyListeners();

    if (_phoneNumbers.isNotEmpty) {
      _startSending();
    } else {
      _isRunning = false;
      notifyListeners();
    }
  }

  void _startSending() async {
    final List<String> successfulThisRun = [];
    final List<String> failedThisRun = [];
    for (int i = _currentIndex; i < _phoneNumbers.length; i++) {
      if (_isPaused) {
        _currentIndex = i;
        notifyListeners();
        return;
      }
      _currentIndex = i;
      notifyListeners();
      String number = _phoneNumbers[i];
      final Uri whatsappUrl = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(_message)}');
      try {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        successfulThisRun.add(number);
      } catch (e) {
        print("Could not launch WhatsApp for $number. Error: $e");
        failedThisRun.add(number);
      }
      await _startCountdown();
    }
    _isRunning = false;
    await _saveCampaignToHistory(
      successfulNumbers: successfulThisRun,
      failedNumbers: failedThisRun,
    );
    notifyListeners();
  }

  Future<void> _startCountdown() {
    final completer = Completer<void>();
    _countdownSeconds = _delayInSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        _countdownSeconds--;
      } else {
        timer.cancel();
        completer.complete();
      }
      notifyListeners();
    });
    return completer.future;
  }

  Future<void> _saveCampaignToHistory({
    required List<String> successfulNumbers,
    required List<String> failedNumbers,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final int successfulCount = successfulNumbers.length;
    final int totalAttempted = successfulNumbers.length + failedNumbers.length;

    await userRef.collection('campaigns').add({
      'name': _campaignName,
      'date': Timestamp.now(),
      'message': _message,
      'totalSent': totalAttempted,
      'successful': successfulNumbers,
      'failed': failedNumbers,
    });

    await userRef.update({
      'stats.totalMessagesSent': FieldValue.increment(successfulCount),
      'stats.totalCampaignsSent': FieldValue.increment(1),
    });
    
    print("Campaign saved and user stats updated!");
  }

  void pauseCampaign() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeCampaign() {
    _isPaused = false;
    notifyListeners();
    _startSending();
  }

  void stopCampaign() {
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    _phoneNumbers.clear();
    _currentIndex = 0;
    _countdownSeconds = 0;
    notifyListeners();
  }
}