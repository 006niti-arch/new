// lib/providers/campaign_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignProvider with ChangeNotifier {
  String _campaignName = '';
  List<String> _phoneNumbers = [];
  String _message = '';
  int _delayInSeconds = 17;
  bool _isRunning = false;
  bool _isPausedByUser = false;
  int _currentIndex = 0;
  Timer? _timer;
  int _countdownSeconds = 0;
  String _planError = '';

  // Getters
  int get countdownSeconds => _countdownSeconds;
  List<String> get phoneNumbers => _phoneNumbers;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPausedByUser;
  int get currentIndex => _currentIndex;
  int get totalNumbers => _phoneNumbers.length;
  String get planError => _planError;

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
        final expiryDate = DateTime.now().add(const Duration(days: 15));
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email, 'planType': 'trial', 'planExpiryDate': Timestamp.fromDate(expiryDate),
          'stats': {'totalMessagesSent': 0, 'totalCampaignsSent': 0}
        });
        return true;
      }
      final data = userDoc.data()!;
      final planType = data['planType'] as String?;
      final expiryDate = (data['planExpiryDate'] as Timestamp?)?.toDate();

      if (planType == 'lifetime') return true;
      
      if (planType == 'trial' || planType == 'monthly' || planType == 'yearly') {
        if (expiryDate == null || expiryDate.isBefore(DateTime.now())) {
          _planError = "Your ${planType ?? 'plan'} has expired. Please upgrade to continue.";
          notifyListeners();
          return false;
        }
        return true;
      }
      return true;
    } catch (e) {
      _planError = "Could not verify your plan. Please try again.";
      notifyListeners();
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
    _isPausedByUser = false;
    notifyListeners();

    if (_phoneNumbers.isNotEmpty) {
      _runNextStep();
    } else {
      _finishCampaign(successful: [], failed: []);
    }
  }

  void _runNextStep() async {
    if (!_isRunning || _isPausedByUser) return;
    if (_currentIndex >= _phoneNumbers.length) {
      _finishCampaign(successful: _phoneNumbers, failed: []);
      return;
    }
    
    String number = _phoneNumbers[_currentIndex];
    final Uri whatsappUrl = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(_message)}');
    
    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Could not launch WhatsApp for $number. Error: $e");
    }
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdownSeconds = _delayInSeconds;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        _countdownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _currentIndex++;
        notifyListeners();
        _runNextStep();
      }
    });
  }

  void pauseCampaign() {
    _isPausedByUser = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeCampaign() {
    _isPausedByUser = false;
    notifyListeners();
    _startCountdown();
  }

  void handleAppInactive() {
    if (_isRunning && !_isPausedByUser) {
      _timer?.cancel();
    }
  }

  void handleAppResumed() {
    if (_isRunning && !_isPausedByUser) {
      _startCountdown();
    }
  }

  void stopCampaign() {
    _isRunning = false;
    _isPausedByUser = false;
    _timer?.cancel();
    _currentIndex = 0;
    _countdownSeconds = 0;
    _phoneNumbers.clear();
    notifyListeners();
  }
  
  void _finishCampaign({required List<String> successful, required List<String> failed}) async {
    _isRunning = false;
    notifyListeners();
    await _saveCampaignToHistory(successfulNumbers: successful, failedNumbers: failed);
  }

  Future<void> _saveCampaignToHistory({
    required List<String> successfulNumbers,
    required List<String> failedNumbers,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final int successfulCount = successfulNumbers.length;
    await userRef.collection('campaigns').add({
      'name': _campaignName,
      'date': Timestamp.now(),
      'message': _message,
      'totalSent': successfulNumbers.length + failedNumbers.length,
      'successful': successfulNumbers,
      'failed': failedNumbers,
    });
    await userRef.update({
      'stats.totalMessagesSent': FieldValue.increment(successfulCount),
      'stats.totalCampaignsSent': FieldValue.increment(1),
    });
  }
}