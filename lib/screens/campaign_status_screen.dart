// lib/screens/campaign_status_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sender/providers/campaign_provider.dart';

class CampaignStatusScreen extends StatefulWidget {
  const CampaignStatusScreen({super.key});

  @override
  State<CampaignStatusScreen> createState() => _CampaignStatusScreenState();
}

class _CampaignStatusScreenState extends State<CampaignStatusScreen> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final campaign = Provider.of<CampaignProvider>(context, listen: false);

    // This is the new, robust logic
    switch (state) {
      case AppLifecycleState.resumed:
        // When the app comes back, RESUME the campaign
        campaign.resumeCampaign();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // When the app goes away, PAUSE the campaign
        campaign.pauseCampaign();
        break;
    }
  }

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
            onWillPop: () async {
              if (campaign.isRunning) {
                campaign.stopCampaign();
              }
              return true;
            },
            child: Center(
              child: campaign.isRunning
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sending ${campaign.currentIndex + 1} of ${campaign.totalNumbers}', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: LinearProgressIndicator(
                            value: (campaign.currentIndex + 1) / campaign.totalNumbers,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text('Current Number:', style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          campaign.phoneNumbers.isNotEmpty ? campaign.phoneNumbers[campaign.currentIndex] : "",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 30),
                        if (campaign.isPaused)
                          const Text('Campaign Paused', style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold))
                        else
                          Text('Next message in: ${campaign.countdownSeconds}s', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 30),
                        // Note: Manual pause/resume is now handled by the system automatically
                        // but we keep the button for user control.
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
                        const SizedBox(height: 20),
                        TextButton.icon(
                          icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
                          label: const Text('Stop Campaign', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            campaign.stopCampaign();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 80),
                        const SizedBox(height: 20),
                        Text('Campaign Finished!', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          child: const Text('Go Home'),
                          onPressed: () {
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