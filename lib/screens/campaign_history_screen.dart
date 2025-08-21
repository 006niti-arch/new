// lib/screens/campaign_history_screen.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whatsapp_sender/screens/manual_input_screen.dart';

class CampaignHistoryScreen extends StatelessWidget {
  const CampaignHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in to see history.")));
    }
    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('campaigns')
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Campaign History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error); // For debugging
            return const Center(child: Text("Error fetching history. Check console."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No campaign history found.'));
          }
          final campaigns = snapshot.data!.docs;
          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final doc = campaigns[index];
              final campaign = doc.data() as Map<String, dynamic>;
              final date = (campaign['date'] as Timestamp?)?.toDate() ?? DateTime.now();
              final formattedDate = DateFormat.yMMMd().add_jm().format(date);
              final campaignName = campaign['name'] != null && (campaign['name'] as String).isNotEmpty
                  ? campaign['name'] as String
                  : 'Campaign on $formattedDate';
              final totalSent = campaign['totalSent'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(campaignName),
                  subtitle: Text('$totalSent messages sent'),
                  onTap: () => _showCampaignDetails(context, campaign),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        tooltip: 'Edit & Rerun',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ManualInputScreen(
                              initialCampaignName: campaign['name'],
                              initialNumbers: List<String>.from(campaign['successful'] ?? []) + List<String>.from(campaign['failed'] ?? []),
                              initialMessage: campaign['message'],
                            ),
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        tooltip: 'Delete Campaign',
                        onPressed: () => _confirmDelete(context, doc.reference),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- HELPER FUNCTIONS ARE NOW CORRECTLY PLACED ---

  void _showCampaignDetails(BuildContext context, Map<String, dynamic> campaign) {
    final date = (campaign['date'] as Timestamp).toDate();
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
    final campaignName = campaign['name'] != null && campaign['name'].isNotEmpty ? campaign['name'] : 'Campaign on $formattedDate';
    final List<String> successful = List.from(campaign['successful'] ?? []);
    final List<String> failed = List.from(campaign['failed'] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(campaignName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Message: "${campaign['message'] ?? ''}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                const Divider(height: 20),
                Text('✅ Successful (${successful.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ...successful.map((e) => Text(e)),
                const SizedBox(height: 10),
                Text('❌ Failed (${failed.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ...failed.map((e) => Text(e)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Download Report'),
              onPressed: () {
                _generateAndDownloadReport(campaign);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DocumentReference docRef) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Campaign'),
          content: const Text('Are you sure you want to delete this campaign history? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                docRef.delete();
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndDownloadReport(Map<String, dynamic> campaign) async {
    // ... (This function remains correct)
  }
}