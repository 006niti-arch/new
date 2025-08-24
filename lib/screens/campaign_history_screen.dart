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
import 'package:whatsapp_sender/screens/edit_campaign_screen.dart';

class CampaignHistoryScreen extends StatefulWidget {
  const CampaignHistoryScreen({super.key});
  @override
  State<CampaignHistoryScreen> createState() => _CampaignHistoryScreenState();
}

class _CampaignHistoryScreenState extends State<CampaignHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Please log in.")));
    
    final query = FirebaseFirestore.instance
        .collection('users').doc(user.uid).collection('campaigns')
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Campaign History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Campaign Name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching history."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No campaign history found.'));
                }

                final allCampaigns = snapshot.data!.docs;
                final filteredCampaigns = allCampaigns.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredCampaigns.isEmpty) {
                  return const Center(child: Text('No campaigns match your search.'));
                }

                return ListView.builder(
                  itemCount: filteredCampaigns.length,
                  itemBuilder: (context, index) {
                    final doc = filteredCampaigns[index];
                    final campaign = doc.data() as Map<String, dynamic>;
                    final date = (campaign['date'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
                    final campaignName = campaign['name'] != null && (campaign['name'] as String).isNotEmpty
                        ? campaign['name'] as String
                        : 'Campaign on $formattedDate';
                    final totalSent = campaign['totalSent'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(campaignName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$totalSent messages sent'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
                              tooltip: 'Edit & Rerun',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCampaignScreen(
                                      campaignName: campaign['name'] ?? 'Untitled Campaign',
                                      message: campaign['message'] ?? '',
                                      numbers: List<String>.from(campaign['successful'] ?? []) + List<String>.from(campaign['failed'] ?? []),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // THIS IS THE RESTORED DELETE BUTTON
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                              tooltip: 'Delete Campaign',
                              onPressed: () => _confirmDelete(context, doc.reference),
                            ),
                          ],
                        ),
                        onTap: () => _showCampaignDetails(context, campaign),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCampaignDetails(BuildContext context, Map<String, dynamic> campaign) {
    final successful = List<String>.from(campaign['successful'] ?? []);
    final failed = List<String>.from(campaign['failed'] ?? []);
    final totalSent = campaign['totalSent'] ?? 0;
    final int durationInSeconds = totalSent * 8;
    final Duration campaignDuration = Duration(seconds: durationInSeconds);
    final String durationString = "${campaignDuration.inMinutes}m ${campaignDuration.inSeconds.remainder(60)}s";
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(campaign['name'] ?? 'Campaign Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Message Preview:', style: Theme.of(context).textTheme.bodySmall),
                Text('"${campaign['message'] ?? ''}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                const Divider(height: 20),
                ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text('Successful: ${successful.length}')),
                ListTile(leading: const Icon(Icons.cancel, color: Colors.red), title: Text('Failed/Skipped: ${failed.length}')),
                ListTile(leading: const Icon(Icons.timer_outlined), title: Text('Est. Duration: $durationString')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Report'),
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
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Campaign'),
      content: const Text('Are you sure you want to delete this campaign history? This action cannot be undone.'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            docRef.delete();
            Navigator.of(ctx).pop();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
  
  Future<void> _generateAndDownloadReport(Map<String, dynamic> campaign) async {
    final List<List<dynamic>> csvData = [
      ['PhoneNumber', 'Status'],
      ...List<String>.from(campaign['successful'] ?? []).map((number) => [number, 'Successful']),
      ...List<String>.from(campaign['failed'] ?? []).map((number) => [number, 'Failed']),
    ];
    String csv = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csv);
    final date = (campaign['date'] as Timestamp).toDate();
    final fileName = 'Report_${campaign['name'] ?? DateFormat('yyyy-MM-dd').format(date)}.csv';
    
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute("download", fileName)..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = XFile.fromData(bytes, mimeType: 'text/csv', name: fileName);
      await Share.shareXFiles([file], text: 'Campaign Report');
    }
  }
}