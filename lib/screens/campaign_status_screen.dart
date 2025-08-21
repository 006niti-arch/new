// lib/screens/campaign_status_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sender/providers/campaign_provider.dart';

class CampaignStatusScreen extends StatelessWidget {
  const CampaignStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignProvider>(
      builder: (context, campaign, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Campaign in Progress'),
            automaticallyImplyLeading: !campaign.isRunning,
          ),
          body: WillPopScope(
            onWillPop: () async => !campaign.isRunning,
            child: Center(
              child: campaign.isRunning
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sending ${campaign.currentIndex + 1} of ${campaign.totalNumbers}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: LinearProgressIndicator(
                            value: (campaign.currentIndex + 1) / campaign.totalNumbers,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Current Number:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          campaign.phoneNumbers.isNotEmpty ? campaign.phoneNumbers[campaign.currentIndex] : "",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 30),
                        if (campaign.isPaused)
                          const Text('Campaign Paused', style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold))
                        else
                          Text(
                            'Next message in: ${campaign.countdownSeconds}s',
                            style: const TextStyle(fontSize: 18),
                          ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: Icon(campaign.isPaused ? Icons.play_arrow : Icons.pause),
                          label: Text(campaign.isPaused ? 'Resume Sending' : 'Pause Sending'),
                          onPressed: () {
                            if (campaign.isPaused) {
                              campaign.resumeCampaign();
                            } else {
                              campaign.pauseCampaign();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: campaign.isPaused ? Colors.green : Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 80),
                        const SizedBox(height: 20),
                        Text(
                          'Campaign Finished!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          child: const Text('Go Home'),
                          onPressed: () {
                            campaign.stopCampaign();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}