// lib/screens/manual_input_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:whatsapp_sender/providers/campaign_provider.dart';
import 'package:whatsapp_sender/screens/campaign_status_screen.dart';

class ManualInputScreen extends StatefulWidget {
  final String? initialCampaignName;
  final List<String>? initialNumbers;
  final String? initialMessage;

  const ManualInputScreen({
    super.key,
    this.initialCampaignName,
    this.initialNumbers,
    this.initialMessage,
  });

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _campaignNameController = TextEditingController();
  final _numbersController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCountryCode = '+91';
  double _delayValue = 8.0;
  bool _canSubmit = false;
  final String _unsubText = 'Reply "STOP" to unsubscribe.';
  bool _isMessagePristine = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCampaignName != null) {
      _campaignNameController.text = widget.initialCampaignName!;
    }
    if (widget.initialNumbers != null) {
      _numbersController.text = widget.initialNumbers!
          .map((e) => e.startsWith('+') ? e : e.replaceAll(RegExp(r'^\+\d+'), ''))
          .join('\n');
    }
    if (widget.initialMessage != null) {
      _messageController.text = widget.initialMessage!;
      _isMessagePristine = false;
    }

    _campaignNameController.addListener(_validateForm);
    _messageController.addListener(_validateForm);
    _validateForm();
  }

  void _validateForm() {
    final messageBody = _messageController.text.replaceAll(_unsubText, '').trim();
    final isFormValid = _campaignNameController.text.trim().isNotEmpty && messageBody.isNotEmpty;
    if (_canSubmit != isFormValid) {
      setState(() {
        _canSubmit = isFormValid;
      });
    }
  }

  void _onMessageChanged(String text) {
    if (_isMessagePristine) return;
    String body = text.replaceAll(_unsubText, '').trim();
    String newText = '$body\n\n$_unsubText';
    if (text != newText) {
      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: body.length),
      );
    }
  }
  
  void _onMessageTap() {
    if (_isMessagePristine) {
      setState(() {
        _messageController.text = '\n\n$_unsubText';
        _isMessagePristine = false;
      });
      _messageController.selection = const TextSelection.collapsed(offset: 0);
    }
  }

  @override
  void dispose() {
    _campaignNameController.removeListener(_validateForm);
    _messageController.removeListener(_validateForm);
    _campaignNameController.dispose();
    _numbersController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Send Campaign')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Campaign Name (Mandatory)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _campaignNameController,
              decoration: const InputDecoration(
                hintText: 'e.g., July Promotion',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const Divider(height: 30),
            const Text('2. Set Default Country Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            CountryCodePicker(
              onChanged: (countryCode) {
                _selectedCountryCode = countryCode.dialCode ?? '+91';
              },
              initialSelection: 'IN',
              favorite: const ['+91', 'IN'],
            ),
            const Divider(height: 30),
            const Text("3. Add or Paste Phone Numbers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text("Numbers without a '+' will use the default country code above."),
            const SizedBox(height: 8),
            TextField(
              controller: _numbersController,
              decoration: const InputDecoration(
                hintText: '9876543210\n+14155552671\n...',
                prefixIcon: Icon(Icons.phone_iphone),
              ),
              maxLines: 8,
              keyboardType: TextInputType.multiline,
            ),
            const Divider(height: 30),
            const Text('4. Compose Your Message (Mandatory)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              onTap: _onMessageTap,
              onChanged: _onMessageChanged,
              // THIS IS THE FIX
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Enter your message here...',
                prefixIcon: Icon(Icons.message_outlined),
              ),
              maxLines: 5,
            ),
            const Divider(height: 30),
            Text('5. Set Message Delay: ${_delayValue.toInt()} seconds', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _delayValue,
              min: 5,
              max: 60,
              divisions: 11,
              label: '${_delayValue.toInt()}s',
              onChanged: (value) {
                setState(() {
                  _delayValue = value;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text('Start Campaign'),
                onPressed: _canSubmit ? () {
                  final numbers = _numbersController.text
                      .split('\n')
                      .where((s) => s.trim().isNotEmpty)
                      .map((number) {
                        final trimmed = number.trim();
                        if (trimmed.startsWith('+')) return trimmed;
                        return '$_selectedCountryCode${trimmed.replaceAll(RegExp(r'\D'), '')}';
                      })
                      .toList();
                  if (numbers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please add at least one phone number.")),
                    );
                    return;
                  }
                  Provider.of<CampaignProvider>(context, listen: false).setupCampaign(
                    campaignName: _campaignNameController.text.trim(),
                    numbers: numbers,
                    message: _messageController.text.trim(),
                    delay: _delayValue.toInt(),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CampaignStatusScreen()),
                  );
                } : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}