// lib/screens/edit_campaign_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sender/providers/campaign_provider.dart';
import 'package:whatsapp_sender/screens/campaign_status_screen.dart';

class EditCampaignScreen extends StatefulWidget {
  final String campaignName;
  final String message;
  final List<String> numbers;

  const EditCampaignScreen({
    super.key,
    required this.campaignName,
    required this.message,
    required this.numbers,
  });

  @override
  State<EditCampaignScreen> createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends State<EditCampaignScreen> {
  late TextEditingController _campaignNameController;
  late TextEditingController _messageController;
  late TextEditingController _numbersController;
  double _delayValue = 8.0;

  @override
  void initState() {
    super.initState();
    _campaignNameController = TextEditingController(text: widget.campaignName);
    _messageController = TextEditingController(text: widget.message);
    _numbersController = TextEditingController(text: widget.numbers.join('\n'));
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _messageController.dispose();
    _numbersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit & Rerun Campaign')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Campaign Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _campaignNameController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.label_outline)),
            ),
            const Divider(height: 30),
            const Text('2. Phone Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _numbersController,
              maxLines: 8,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_iphone)),
            ),
            const Divider(height: 30),
            const Text('3. Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                // THIS IS THE NEW HINT TEXT
                hintText: 'Enter your message here...',
                prefixIcon: Icon(Icons.message_outlined)
              ),
            ),
            const Divider(height: 30),
            Text('4. Set Message Delay: ${_delayValue.toInt()} seconds', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _delayValue,
              min: 5,
              max: 60,
              divisions: 11,
              label: '${_delayValue.toInt()}s',
              onChanged: (value) => setState(() => _delayValue = value),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.replay_circle_filled_rounded),
                label: const Text('Rerun Campaign'),
                onPressed: () {
                  final numbers = _numbersController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
                  if (numbers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please add at least one number to rerun the campaign.")),
                    );
                    return;
                  }
                  Provider.of<CampaignProvider>(context, listen: false).setupCampaign(
                    campaignName: _campaignNameController.text.trim(),
                    numbers: numbers,
                    message: _messageController.text.trim(),
                    delay: _delayValue.toInt(),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CampaignStatusScreen()),
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}